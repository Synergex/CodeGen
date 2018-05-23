;;*****************************************************************************
;;
;; Title:       Create<StructureName>File.dbl
;;
;; Type:        Function
;;
;; Author:      Steve Ives, Synergex Professional Services Group
;;
;;*****************************************************************************
;;
;; Copyright (c) 2018, Synergex International, Inc.
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; * Redistributions of source code must retain the above copyright notice,
;;   this list of conditions and the following disclaimer.
;;
;; * Redistributions in binary form must reproduce the above copyright notice,
;;   this list of conditions and the following disclaimer in the documentation
;;   and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;
;; POSSIBILITY OF SUCH DAMAGE.
;;*****************************************************************************
;;

import System.Collections

function Create<StructureName>File, boolean
	required in  aReplaceFile, boolean
	optional in  aFileSpec,    string
	optional out aErrorText,    string
	endparams
	
	.define append(x,y)			x = %atrim(x) + y
		
	stack record
		ok,					boolean
		errorText,			string
		fileSpec,			string
		fileExists,			boolean
		isamc_filespec,		string
		keydata,			@ArrayList
	endrecord
		
	local record
		key_order,	2a1	,'A'    ;;ascending
		&				,'D'    ;;descending
		key_segtyp,	7a1	,'A'    ;;alpha (default)
		&				,'N'    ;;nocase
		&				,'D'    ;;decimal
		&				,'I'    ;;integer
		&				,'U'    ;;unsigned
		&				,'S'    ;;sequence
		&				,'T'    ;;timestamp
	endrecord
		
proc

	ok = true
	errorText = String.Empty

	;;Make sure there are keys defined
	if (<STRUCTURE_KEYS>==0)
	begin
		errorText = "ERROR: No keys defined!"
		ok = false
	end

	;;Determine the name of the file to be created
	if(ok)
		fileSpec = ^passed(aFileSpec) ? aFileSpec.Trim() : "<FILE_NAME>"

	;;Replace existing file?
	if (ok)
	begin
		;;Does the file exist?
		try
		begin
			data tmpch, i4, 0
			open(tmpch,I,fileSpec)
			close tmpch
			fileExists = true
		end
		catch (e, @Exception)
		begin
			fileExists = false
		end
		endtry
		
		;;Should we replace an existing file?
		if (fileExists&&!aReplaceFile)
		begin
			errorText = "ERROR: File already exists!"
			ok = false
		end
	end
	
	;;Create the file
	if (ok)
	begin
		<IF STRUCTURE_ISAM>
		data key_idx, i4
			
		;;Build the ISAMC file specification string
			
		;;File specification and record type
		isamc_filespec = String.Format("{0},<FILE_RECTYPE>",fileSpec)

		<IF FILE_COMPRESSION>
		;;Data compression
		isamc_filespec = String.Format("{0},COMPRESS",isamc_filespec)

		</IF FILE_COMPRESSION>
		;;Default key density
		data keyDensity = <FILE_DENSITY>
		if (keyDensity < 50)
			keyDensity = 50
		isamc_filespec = String.Format("{0},DENSITY={1}",isamc_filespec,keyDensity)
			
		;;Portable integer specs
		<IF FILE_PORTABLE_INT_SPECS>
		data intSpecs = "<FILE_PORTABLE_INT_SPECS>"
		intSpecs = intSpecs.ToUpper()
		if (intSpecs.StartsWith("I=")) then
			isamc_filespec = String.Format("{0},{1}",isamc_filespec,intSpecs)
		else
			isamc_filespec = String.Format("{0},I={1}",isamc_filespec,intSpecs)
			
		</IF FILE_PORTABLE_INT_SPECS>
			
		;;Page size
		isamc_filespec = String.Format("{0},PAGE=<FILE_PAGESIZE>",isamc_filespec)

		<IF FILE_STORED_GRFA>
		;;Stored GRFA
		isamc_filespec = String.Format("{0},SGRFA",isamc_filespec)

		</IF FILE_STORED_GRFA>
		<IF FILE_STATIC_RFA>
		;;Static RFA
		isamc_filespec = String.Format("{0},STATIC_RFA",isamc_filespec)

		</IF FILE_STATIC_RFA>
		<IF FILE_TERABYTE>
		;;Terabyte
		isamc_filespec = String.Format("{0},TBYTE",isamc_filespec)
			
		</IF FILE_TERABYTE>
		<IF FILE_CHANGE_TRACKING>
		;;Track changes
		isamc_filespec = String.Format("{0},TRACK_CHANGES",isamc_filespec)
		</IF FILE_CHANGE_TRACKING>
	end

	;;Now for the keys
	if (ok)
	begin
		keydata = new ArrayList()
		data isamc_keyspec = String.Empty

		<COUNTER_1_RESET>
		<KEY_LOOP>
		;;Make sure that key sequence and any key of reference specified match for key index <COUNTER_1_VALUE>
		if (((<COUNTER_1_VALUE>==0&&<KEY_NUMBER>!=0))||(<COUNTER_1_VALUE>>0&&<KEY_NUMBER>>0&&<KEY_NUMBER>!=<COUNTER_1_VALUE>))
		begin
			errorText = "ERROR: Key of reference settings don't match key position numbers for key <COUNTER_1_VALUE>!"
			ok = false
		end

		;;Build the ISAMC key specification string
		if (ok)
		begin
			data keyDensity = <KEY_DENSITY>
			if (keyDensity<50)
				keyDensity = 50

			isamc_keyspec = "NAME=<KEY_NAME>"

			isamc_keyspec = String.Format("{0},START=<SEGMENT_LOOP><SEGMENT_POSITION><:><SEGMENT_LOOP>",isamc_keyspec)
			isamc_keyspec = String.Format("{0},LENGTH=<SEGMENT_LOOP><SEGMENT_LENGTH><:><SEGMENT_LOOP>",isamc_keyspec)
			isamc_keyspec = String.Format("{0},TYPE=<SEGMENT_LOOP><SEGMENT_TYPE><:><SEGMENT_LOOP>",isamc_keyspec)
			isamc_keyspec = String.Format("{0},ORDER=<SEGMENT_LOOP><SEGMENT_ORDER_CODE><:><SEGMENT_LOOP>",isamc_keyspec)
			isamc_keyspec = String.Format("{0},DENSITY={1}",isamc_keyspec,keyDensity)
			isamc_keyspec = String.Format("{0},<IF DUPLICATES>DUPS,<IF DUPLICATESATFRONT>NOATEND<ELSE>ATEND</IF DUPLICATESATFRONT><ELSE>NODUPS</IF DUPLICATES>",isamc_keyspec)
			isamc_keyspec = String.Format("{0},<IF CHANGES>MODIFY<ELSE>NOMODIFY</IF CHANGES>",isamc_keyspec)
			isamc_keyspec = String.Format("{0},<IF ASCENDING>ASCEND<ELSE>NOASCEND</IF ASCENDING>",isamc_keyspec)
			isamc_keyspec = String.Format("{0}",isamc_keyspec)
			isamc_keyspec = String.Format("{0}",isamc_keyspec)

			.ifdef OS_VMS
			if (k_info.ki_cmpidx||k_info.ki_cmprec||k_info.ki_cmpkey)
			begin
				;;All options?
				if (k_info.ki_cmpidx&&k_info.ki_cmprec&&k_info.ki_cmpkey) then
					append(isamc_keyspec,',COMPRESS=ALL')
				else
				begin
					if (k_info.ki_cmpidx)
						append(isamc_keyspec,',COMPRESS=INDEX')
					if (k_info.ki_cmprec)
						append(isamc_keyspec,',COMPRESS=RECORD')
					if (k_info.ki_cmpkey)
						append(isamc_keyspec,',COMPRESS=KEY')
				end
			end
			.endc
				
			;;Null key?
			using k_info.ki_null select
			(KI_REP),
				append(isamc_keyspec,',NULL=REPLICATE')
			(KI_NONREP),
				append(isamc_keyspec,',NULL=NOREPLICATE')
			(KI_SHORT),
				append(isamc_keyspec,',NULL=SHORT')
			endusing
				
			;;Null key value
			if (k_info.ki_nullval)
			begin
				data nullval, a255
				xcall dd_key(dcs, DDK_TEXT, k_info.ki_nullval, nullval)
				append(isamc_keyspec,',VALUE_NULL='+%atrim(nullval))
			end

			keydata.Add(isamc_keyspec)
		end
				
		</KEY_LOOP>



		;;Create the file
		if (ok)
		begin
			try
			begin
				xcall isamc(%atrim(isamc_filespec),fls_info.flsi_recsz,fls_info.flsi_nmkeys,isamc_keyspec)
			end
			catch (e, @Exception)
			begin
				errorText = "ERROR: Failed to create file, " + e.Message
				ok = false
			end
			endtry
		end
		</IF>
		<IF STRUCTURE_RELATIVE>
		errorText = "ERROR: Creating relative files is not currently supported!"
		ok = false
		</IF>
		<IF STRUCTURE_ASCII>
		errorText = "ERROR: Creating sequential files is not currently supported!"
		ok = false
		</IF>
		<IF STRUCTURE_USER_DEFINED>
		errorText = "ERROR: Creating user defined files is not currently supported!"
		ok = false
		</IF>
	end

	if (ok)
		errorText = fileExists ? "file replaced" : "file created"	

	if (^passed(aErrorText))
		aErrorText = errorText

	freturn ok

endfunction
