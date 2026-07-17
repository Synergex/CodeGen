# RepositoryAPI

`RepositoryAPI` is a Synergy .NET class library for reading metadata from a
Synergy Repository database. It wraps the Synergy/DE `ddlib` API in an object
model rooted at `CodeGen.RepositoryAPI.Repository`.

Use it to inspect repository structures, fields, files, keys, templates,
formats, enumerations, relations, and tags. The library also derives metadata
that is useful to CodeGen consumers, such as language-specific data types and
names suitable for SQL and xfODBC.

> This is a metadata reader. Although a number of model properties have public
> setters, the library contains no API that writes the changed objects back to
> the Repository. Treat the loaded objects as an in-memory snapshot.

## Contents

- [Project and runtime requirements](#project-and-runtime-requirements)
- [Quick start](#quick-start)
- [Repository lifecycle](#repository-lifecycle)
- [Metadata object graph](#metadata-object-graph)
- [Repository API](#repository-api)
- [Metadata models](#metadata-models)
- [Collections and loading behavior](#collections-and-loading-behavior)
- [CodeGen extensions and data mappings](#codegen-extensions-and-data-mappings)
- [Enums](#enums)
- [Errors and lookup behavior](#errors-and-lookup-behavior)
- [JSON considerations](#json-considerations)

## Project and runtime requirements

The project targets **.NET Standard 2.0** and its public types are in the
`CodeGen.RepositoryAPI` namespace. It depends on these Synergy/DE components:

- `Synergex.SynergyDE.ddlib` to access Repository metadata;
- `Synergex.SynergyDE.synrnt` for the Synergy runtime;
- `Synergex.SynergyDE.synxml` when using custom data mappings; and
- `Newtonsoft.Json` for serialization attributes.

The default project at `DotNetCore/RepositoryAPI/RepositoryAPI.synproj`
compiles the Synergy source held in the sibling `CodeGen/RepositoryAPI`
directory. A consuming application must be able to locate the Synergy runtime
and either:

- have a default Repository configured for `dd_init`; or
- supply the Repository main and text file paths when opening the API.

## Quick start

This C# example opens a specific Repository, retrieves one structure, and
walks its field and key metadata.

```csharp
using System;
using System.Linq;
using CodeGen.RepositoryAPI;

var mainFile = @"C:\SynergyDE\rps\rpsmain.ism";
var textFile = @"C:\SynergyDE\rps\rpstext.ism";

using (var repository = new Repository(mainFile, textFile, true))
{
    // `true` makes RpsField.Name use the Repository alternate name when set.
    var customer = repository.GetStructure("CUSTOMER");

    Console.WriteLine($"{customer.Name}: {customer.Length} bytes");

    foreach (var field in customer.Fields)
    {
        Console.WriteLine(
            $"{field.SequenceNumber,2} {field.Name,-30} " +
            $"{field.DataType}/{field.DataTypeSubclass} " +
            $"offset={field.StartPosition} size={field.Size}");
    }

    var primaryKey = customer.Keys.FirstOrDefault(k => k.SequenceNumber == 1);
    if (primaryKey != null)
    {
        Console.WriteLine($"Key: {primaryKey.Name}");
        foreach (var segment in primaryKey.Segments)
            Console.WriteLine($"  {segment.SegmentType}: {segment.Field}");
    }
}
```

To inspect every structure instead, enumerate `repository.Structures`. To
avoid loading the complete Repository when only one item is needed, prefer
`GetStructure`, `GetFile`, or `GetTemplate`.

## Repository lifecycle

`Repository` implements `IDisposable`. Dispose it when finished so that the
underlying `ddlib` session is closed and its cached collections are released.

| Construction or method | Behavior |
| --- | --- |
| `new Repository()` | Creates an empty, unopened Repository object. Call `Open()` before using it. |
| `new Repository(bool useAlternateFieldNames)` | Opens the default Repository immediately. |
| `new Repository(string mainFile, string textFile, bool useAlternateFieldNames = false)` | Opens the supplied Repository files immediately. |
| `Open()` | Closes any current Repository and opens the default Repository. |
| `Open(mainFile, textFile)` | Closes any current Repository and opens the supplied files. |
| `Dispose()` | Closes the Repository and clears cached root collections. |
| `CheckIsOpen()` | Ensures a `ddlib` session is open, opening the default Repository when necessary. Model constructors use this before loading metadata. |

After opening, these properties describe the session:

- `MainFile` and `TextFile` — resolved Repository file specifications.
- `LastModified` — Repository modification timestamp (`YYYYMMDDHHMMSS`).
- `LastStructureAddDelete` — timestamp for the last structure add/delete.
- `Version` — Repository version string.

### Name handling and alternate names

Repository names supplied to lookups are trimmed and generally normalized to
uppercase by the model loaders. Fields retain both the actual Repository name
and the alternate name:

- With `useAlternateFieldNames: false` (the default), `RpsField.Name` is the
  actual Repository name.
- With `useAlternateFieldNames: true`, `RpsField.Name` is the alternate name
  when one is defined; otherwise it remains the actual name.
- `RpsField.OriginalName` always records the actual Repository name initially.

## Metadata object graph

```text
Repository
├── Structures : RpsStructureCollection
│   └── RpsStructure
│       ├── Fields    : RpsFieldCollection
│       ├── Keys      : RpsKeyCollection
│       │   └── RpsKey.Segments : RpsKeySegmentCollection
│       ├── Files     : RpsFileCollection
│       ├── Tags      : RpsTagCollection
│       ├── Formats   : RpsFormatCollection
│       └── Relations : RpsRelationCollection
├── Files        : RpsFileCollection
│   └── RpsFile.Structures / Keys
├── Templates    : RpsTemplateCollection
├── Formats      : RpsFormatCollection       (global formats)
├── DateFormats  : RpsFormatCollection       (predefined date formats)
├── TimeFormats  : RpsFormatCollection       (predefined time formats)
└── Enumerations : RpsEnumCollection
    └── RpsEnum.Members : RpsEnumMemberCollection
```

The graph intentionally contains navigation in both directions between files
and structures. JSON-related navigation properties are ignored to prevent
cycles; see [JSON considerations](#json-considerations).

## Repository API

The main entry point exposes the following cached collections and targeted
loaders.

| Member | Returns | Description |
| --- | --- | --- |
| `Structures` | `RpsStructureCollection` | Every Repository structure. |
| `GetStructure(name)` | `RpsStructure` | Loads one named structure. A dotted name such as `ORDER.HEADER` selects an explicit group as a synthetic structure. |
| `Files` | `RpsFileCollection` | Every Repository file definition. |
| `GetFile(name)` | `RpsFile` | Loads one file definition. |
| `Templates` | `RpsTemplateCollection` | Every Repository template. |
| `GetTemplate(name)` | `RpsTemplate` | Loads one template. |
| `Formats` | `RpsFormatCollection` | Global display formats. |
| `DateFormats` | `RpsFormatCollection` | Predefined date formats. |
| `TimeFormats` | `RpsFormatCollection` | Predefined time formats. |
| `GetFormat(name)` | `RpsFormat` | Loads a global format by name. |
| `Enumerations` | `RpsEnumCollection` | Every Synergy language enumeration. |

## Metadata models

The following types carry the loaded Repository metadata. Collections are
`List<T>` derivatives, while the individual metadata objects expose direct
attributes and CodeGen-derived values.

### Structures and groups

`RpsStructure` is the central metadata type. A normally loaded structure
includes its fields, keys, associated files, tags, local formats, and
relations.

| Property group | Properties |
| --- | --- |
| Identity and text | `Name`, `Description`, `LongDescription`, `UserText`, `Alias` |
| Physical definition | `FileType`, `Length`, `ChildCount`, `TagType`, `FirstFile` |
| Children | `Fields`, `Keys`, `Files`, `Tags`, `Formats`, `Relations` |
| CodeGen metadata | `MappedStructure`, `MappedFileSpec`, `DisplayField`, `IsFake` |
| Raw interop | `ddlib_s_info` exposes the underlying `s_info` record. |

An explicit group can be addressed as `STRUCTURE.GROUP`. The loader validates
that the requested field is an explicit group, promotes its member fields into
a synthetic `RpsStructure`, and sets `IsFake` to `true`. The synthetic
structure has no Repository files, keys, tags, formats, or relations.

An implicit group remains a field with `GroupStructure` naming the source
structure and `GroupFields` containing fields loaded from that structure.

### Fields

`RpsField` describes a physical Repository field plus UI, validation, and
CodeGen information. The field object is loaded with the structure, including
its extended text records, allowed values, selection values, numeric ranges,
group members, and enumeration reference where applicable.

| Property group | Properties |
| --- | --- |
| Identity and descriptions | `StructureName`, `Name`, `OriginalName`, `OriginalNameModified`, `BaseName`, `AlternateName`, `Description`, `LongDescription`, `UserText` |
| Storage and type | `DataType`, `DataTypeCode`, `DataTypeSubclass`, `Size`, `NativeSize`, `Precision`, `ArrayDimension`, `SequenceNumber`, `StartPosition`, `Template`, `UserFieldType`, `EnumName`, `CoercedType`, `StructFieldStructure` |
| Overlays and groups | `OverlaysField`, `OverlayOffset`, `IsGroup`, `GroupType`, `GroupFields`, `GroupStructure`, `GroupMemberPrefix`, `GroupSizeEqualsMembers`, `CompilerUsesGroupMemberPrefix` |
| Visibility and formats | `ExcludedByLanguage`, `ExcludedByReportWriter`, `ExcludedByToolkit`, `ExcludedByWeb`, `NoNameLink`, `FormatName`, `FormatString` |
| Screen and report presentation | `InputJustification`, `FieldPositionMode`, `FieldRow`, `FieldColumn`, `PromptPositionMode`, `PromptRow`, `PromptColumn`, `ReportJustification`, `ReportHeading`, `Prompt`, `HelpIdentifier`, `InfoLineText`, `FieldFont`, `PromptFont`, `BlankIfZero`, `PaintField`, `PaintCharacterSpecified`, `PaintCharacter`, `ViewAs`, `ColorPalette`, `RenditionHighlight`, `RenditionReverse`, `RenditionBlink`, `RenditionUnderline`, `DisplayLength`, `ViewLength` |
| Input behavior | `ReadOnly`, `Disabled`, `NoEcho`, `NoEchoCharacter`, `DefaultAction`, `DefaultAuotmatic`, `DateDefaultToday`, `AllowShortDate`, `TimeDefaultNow`, `TimeAmPm`, `InputTimeoutMode`, `InputTimeout`, `Uppercase`, `NoDecimalRequired`, `NoTerminatorRequired`, `RetainPosition`, `InputLength`, `Required`, `BreakMode`, `NegativeAllowed` |
| Validation | `AllowList`, `AllowListMaxLength`, `AllowListMatchCase`, `AllowListMatchExact`, `SelectionList`, `SelectionListMaxLength`, `SelectionListType`, `SelectionWindowRow`, `SelectionWindowColumn`, `SelectionWindowName`, `SelectionWindowHeight`, `NumericRangeExists`, `NumericRangeMinimum`, `NumericRangeMaximum`, `Enumerated`, `EnumeratedDisplayLength`, `EnumeratedBaseValue`, `EnumeratedStepValue` |
| User methods | `DefaultValue`, `ArriveMethod`, `LeaveMethod`, `DrillMethod`, `HyperlinkMethod`, `ChangeMethod`, `DisplayMethod`, `EditFormatMethod` |
| CodeGen extensions | `TypeCode`, `TypeName`, `CsType`, `CsDefault`, `CsNumericConvert`, `DblNetConverterer`, `VbType`, `VbDefault`, `SnType`, `SnDefault`, `SqlType`, `TsType`, `TsDefault`, `OcType`, `OcDefault`, `OcObject`, `MappedField`, `MappingFunction`, `UnmappingFunction`, `AutoIncrement`, `SqlName`, `OdbcName`, `FieldNumber`, `LogicalFieldNumber`, `WasArrayElement`, `OriginalElement` |
| Raw interop | `ddlib_f_info` exposes the underlying `f_info` record. |

`DefaultAuotmatic` is spelled that way in the public API. It indicates whether
the configured default action is applied automatically.

`RpsFieldCollection` inherits `List<RpsField>` and provides these in-place
filters:

- `RemoveOverlays()`
- `RemoveExcludedByLanguage()`
- `RemoveExcludedByToolkit()`
- `RemoveExcludedByReportWriter()`
- `RemoveExcludedByWeb()`

### Files

`RpsFile` describes a Repository file definition and its assigned structures.

| Property group | Properties |
| --- | --- |
| Identity and text | `Name`, `Description`, `LongDescription`, `UserText`, `LastModified` |
| File definition | `FileType`, `FileSpec`, `PortableIntsSpecs`, `TempFile`, `RecordType`, `PageSize`, `Density`, `Addressing`, `RecordCompression`, `StaticRFA`, `ChangeTracking`, `StoredGRFA` |
| Structure assignment | `StructureCount`, `FirstStructure`, `StructureNames`, `OdbcTableNames`, `Structures` |
| Keys and raw data | `Keys`, `ddlib_fl_info` |

`StructureNames` and `OdbcTableNames` are parallel lists in Repository order.
When an assigned structure has no ODBC table name, its structure name is used
in `OdbcTableNames`. `Keys` is populated from the file's first assigned
structure, when one exists.

### Keys and segments

`RpsKey` captures a structure key and has a `Segments` collection. Its main
properties are:

- identity and shape: `SequenceNumber`, `Name`, `KeyType`, `Size`,
  `Description`, `Segments`;
- ordering and duplicates: `SortOrder`, `Duplicates`, `InsertDuplicates`;
- update and null behavior: `Modifiable`, `NullKey`, `NullKeyValue`,
  `KeyOfReference`;
- storage/visibility: `Density`, `CompressIndex`, `CompressData`,
  `CompressKey`, `OdbcAccessible`; and
- raw interop: `ddlib_k_info`.

Each `RpsKeySegment` exposes `SegmentType`, `Position`, `Length`, `Field`,
`Structure`, `LiteralValue`, `DataType`, `DataTypeName`, and `Order`. `Field`
and `Structure` apply to external segments; `LiteralValue` applies to literal
segments. For alpha literal segments, `~` is returned as a space and the
length is calculated from the resulting literal.

### Templates

`RpsTemplate` represents a reusable Repository field template. It mirrors the
field metadata that a template can supply: data type and subclass, size and
precision, array dimensions, format and screen attributes, input behavior,
allow/selection lists, validation ranges, prompt/help text, methods, and
enumeration configuration.

Important template-specific properties are `TemplateNumber`, `Name`,
`ParentTemplate`, `Description`, `LongDescription`, `UserFieldType`,
`DataType`, `DataTypeCode`, `DataTypeSubclass`, `Size`, `Precision`,
`ArrayDimension`, `NativeSize`, `EnumName`, and `CoercedType`.

It also has the CodeGen type and naming properties shared with fields:
`BaseName`, `OriginalName`, `OriginalNameModified`, `TypeCode`, `TypeName`,
`CsType`, `VbType`, `SnType`, `SqlType`, `TsType`, `OcType`, their default
value counterparts, `MappedField`, `MappingFunction`, `UnmappingFunction`,
`AutoIncrement`, `OdbcName`, and `SqlName`.

### Formats, tags, and relations

| Type | Key properties | Meaning |
| --- | --- | --- |
| `RpsFormat` | `Name`, `FormatType`, `FormatString` | A structure-local, global, or predefined date/time display format. |
| `RpsTag` | `Name`, `SequenceNumber`, `ComparisonConnector`, `Field`, `ComparisonOperator`, `ComparisonValue` | One clause in a structure tag. The first clause has `ComparisonConnector = None`. |
| `RpsRelation` | `Name`, `FromStructure`, `FromKey`, `ToStructure`, `ToKey` | A named relationship from a structure/key to another structure/key. |

### Enumerations

`RpsEnum` exposes `Name`, `Description`, `LongDescription`, and lazy-loaded
`Members`. Each `RpsEnumMember` exposes `EnumName`, `Name`, `ExplicitValue`,
and `ImplicitValue`.

When an enumeration member has no explicit value, the collection calculates
its implicit value: the first member is `0`; each later member increments the
previous implicit value. `ExplicitValue` may therefore be blank while
`ImplicitValue` is populated.

## Collections and loading behavior

All `Rps*Collection` types inherit `List<T>` and are ordinary mutable lists.
They are snapshots rather than live Repository queries.

| Collection | Scope | When it loads |
| --- | --- | --- |
| `RpsStructureCollection` | All structures or structures assigned to one file | Root `Repository.Structures` loads all structures on first access. |
| `RpsFieldCollection` | Fields of a structure or explicit group | A structure load materializes its field collection. |
| `RpsFileCollection` | All files or files for one structure | Root `Repository.Files` loads all files on first access. |
| `RpsKeyCollection` | Keys of a structure | A structure load materializes its key collection. |
| `RpsKeySegmentCollection` | Segments of one key | Created while the key is loaded. |
| `RpsTemplateCollection` | All templates | Root `Repository.Templates` loads all templates on first access. |
| `RpsFormatCollection` | Structure-local, global, date, or time formats | Root format properties cache their respective complete collections; a structure materializes its local formats. |
| `RpsTagCollection` | Tags of one structure | A structure load materializes its tag collection. |
| `RpsRelationCollection` | Relations of one structure | A structure load materializes its relation collection. |
| `RpsEnumCollection` | All enumerations, or those referenced by one structure | Root `Repository.Enumerations` loads all enumerations on first access. |
| `RpsEnumMemberCollection` | Members of one enumeration | `RpsEnum.Members` loads on first access. |

Root collection properties are cached for the lifetime of the open
`Repository` instance. `Open(...)` and `Dispose()` clear those cached root
collections. For large Repositories, use targeted getters when possible and
avoid touching root collections merely to test for one name.

## CodeGen extensions and data mappings

In addition to direct Repository attributes, fields and templates calculate
data types for C#, Visual Basic, Synergy .NET, SQL, Objective-C, and
TypeScript. The computed values appear in properties such as `CsType`,
`SqlType`, `SnType`, `TsType`, and their default-value counterparts.

### Repository text directives

The loader checks a structure or field's user text first, then its long
description, for these directives:

| Directive | Applies to | Result |
| --- | --- | --- |
| `@MAP=name;` | Structure | Populates `MappedStructure`; the corresponding file specification becomes `MappedFileSpec`. |
| `@MAP=name;` | Field | Populates `MappedField`. |
| `@MAPF=function;` | Field | Populates `MappingFunction`. |
| `@UNMAPF=function;` | Field | Populates `UnmappingFunction`. |
| `@AUTOINCREMENT;` | Field or template | Sets `AutoIncrement` to `true`. |

Each directive requiring a value must end with `;`. An incomplete or malformed
mapping directive raises an `RpsStructureException` or `RpsFieldException`.

### Custom language and SQL mappings

`DataMappings` creates a `DataMapping` instance for SQL, C#, Visual Basic,
Objective-C, Synergy .NET, and TypeScript. The default SQL mapping is selected
with `CODEGEN_DATABASE_TYPE`:

- `sqlserver` (the default)
- `mysql`
- `postgresql`

Set `CODEGEN_DATAMAPPING_FILE` before any fields or templates are loaded to
override defaults from an XML file. The file root must be `DataMappings`; it
may contain any of the sections `SQL`, `CSharp`, `VisualBasic`, `ObjectiveC`,
`SynergyDotNet`, and `TypeScript`.

```xml
<?xml version="1.0"?>
<DataMappings>
  <CSharp>
    <Alpha>string</Alpha>
    <Integer8>long</Integer8>
  </CSharp>
  <SQL>
    <Alpha>VARCHAR(l)</Alpha>
    <ImpliedDecimal>DECIMAL(l,p)</ImpliedDecimal>
  </SQL>
</DataMappings>
```

Supported individual mappings include `Alpha`, `AlphaBinary`, `UserAlpha`,
`UserNumeric`, `UserDate`, `UserTimeStamp`, the date/time subtypes (including
nullable variants), `ImpliedDecimal`, `SmallDecimal`, `LargeDecimal`,
`VeryLargeDecimal`, `Integer1`, `Integer2`, `Integer4`, `Integer8`, `Boolean`,
`Enum`, `Binary`, `StructField`, `AutoSequence`, and `AutoTime`.

In mapping strings, `(l)` is replaced with the field length; `(l,p)` and
`(l.p)` are replaced with field length and precision. The complete example is
available at `CodeGen/RepositoryAPI/DataMappingsExample.xml`.

## Enums

The API exposes strongly typed enums rather than raw `ddlib` codes. The most
commonly used enums are:

| Area | Enum and members |
| --- | --- |
| Field type | `RpsFieldDataType`: `Alpha`, `Decimal`, `Integer`, `User`, `Boolean`, `Enum`, `Binary`, `StructField`, `AutoSequence`, `AutoTime` |
| Field subtype | `RpsFieldSubclass`: date (`YYMMDD`, `YYYYMMDD`, `YYJJJ`, `YYYYJJJ`, `YYPP`, `YYYYPP`), time (`HHMMSS`, `HHMM`), `Binary`, `UserAlpha`, `UserNumeric`, `UserDate` |
| Coercion | `RpsFieldCoercedType`: `CtNone`, signed/unsigned byte, short, int, and long variants, `CtBoolean`, `CtDouble`, `CtFloat`, `CtNullDateTime` |
| Field UI/input | `RpsJustification`, `RpsPositionMode`, `RpsColorPalette`, `RpsFieldViewAs`, `RpsFieldDefaultAction`, `RpsFieldBreak`, `RpsFieldNegatives`, `RpsFieldTimeout`, `RpsFieldSelectionType`, `RpsFieldGroup` |
| Key | `RpsKeyType`, `RpsKeyOrder`, `RpsKeyDuplicates`, `RpsKeyInsertDups`, `RpsKeyNullType`, `RpsKeySegmentType`, `RpsKeySegmentDataType`, `RpsKeySegmentOrder` |
| File | `RpsRecordType`, `RpsFilePageSize`, `RpsFileAddressing` |
| Format and tags | `RpsFormatType`, `RpsGlobalFormatType`, `RpsTagType`, `RpsTagComparison`, `RpsTagOperator` |
| Loading | `RpsLoadMode`: `NoLoad` or `Load`; `RpsFieldCollectionMode`: `Structure` or `Group` |

`RpsKeySegmentType` distinguishes field, literal, external, and record-number
segments. `RpsKeySegmentDataType` distinguishes alpha/no-case alpha, decimal,
signed/unsigned integer, automatic sequence, and created/updated timestamp
segments. Use the enum properties rather than assuming raw `ddlib` numeric
values.

## Errors and lookup behavior

All library-specific exceptions inherit from `RpsException`, which itself
inherits `ApplicationException`.

| Exception | Typical cause |
| --- | --- |
| `RpsException` | The Repository cannot be opened or a general Repository operation fails. |
| `RpsStructureException` | Structure loading or malformed structure mapping data. |
| `RpsStructureNotFoundException` | `GetStructure` or a structure constructor cannot find the requested structure. |
| `RpsFieldException` | Field loading, group loading, or malformed field mapping data. |
| `RpsFieldNotFoundException` | A requested field, including a dotted explicit-group member, is absent. |
| `RpsFileException` | File definition or file-to-structure metadata cannot be read. |
| `RpsKeyException` | Key or key segment metadata cannot be read. |
| `RpsTemplateException` | Template metadata cannot be read. |
| `RpsFormatException` | Structure or global format metadata cannot be read. |
| `RpsTagException` | Tag metadata cannot be read. |
| `RpsRelationException` | Relation metadata cannot be read. |
| `RpsGroupException` | A group operation is invalid or group metadata cannot be read. |
| `RpsEnumException` | Enumeration or member metadata cannot be read. |
| `RpsDataMappingException` | A custom mapping file has unsupported or invalid mapping data. |

Targeted getters load an object and report failures by throwing one of these
exceptions; they do not return `null` for a missing Repository object. Catch
the most specific exception that your application can handle.

## JSON considerations

The metadata classes use Newtonsoft.Json attributes. Enum-valued properties
are decorated to serialize as names rather than numeric values. Navigation
properties that can create cycles are marked `JsonIgnore`, including:

- `RpsStructure.Files`, `RpsStructure.FirstFile`, and `RpsStructure.IsFake`;
- `RpsFile.Keys` and `RpsFile.Structures`.

When serializing a large Repository graph, choose a bounded projection (for
example, a structure and selected fields) rather than serializing every root
collection. That keeps output manageable and avoids loading unnecessary
metadata.
