using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using Microsoft.Win32;
using System.Runtime.InteropServices;
using System.IO;
using System.Diagnostics;

namespace InstallerCustomActions
{
    [RunInstaller(true)]
    public class InstallerActions : Installer
    {
        [System.Security.Permissions.SecurityPermission(System.Security.Permissions.SecurityAction.Demand)]
        public override void Install(System.Collections.IDictionary savedState)
        {
            base.Install(savedState);

            string curPath = GetPath();
            savedState.Add("previousPath", curPath);
            string newPath = AddPath(curPath, MyPath());
            if (curPath != newPath)
            {
                savedState.Add("changedPath", true);
                SetPath(newPath);
                broadcastSettingsChanged();
            }
            else
                savedState.Add("changedPath", false);

            //Save the install data to the registry

            string installPath = Context.Parameters["Path"].Trim();
            string templatePath = String.Format("{0}Templates\\",installPath);
            string author = Context.Parameters["Author"].Trim();
            string company = Context.Parameters["Company"].Trim();

            Registry.LocalMachine.CreateSubKey(@"SOFTWARE\Synergex\CodeGen");
            RegistryKey key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Synergex\CodeGen",RegistryKeyPermissionCheck.ReadWriteSubTree);
            key.SetValue("InstallPath", installPath);
            key.SetValue("TemplatePath", templatePath);
            key.SetValue("DefaultAuthor", author);
            key.SetValue("DefaultCompany", company);
            key.Close();

            savedState.Add("changedRegistry", true);

            ngen(savedState, "install");
        }

        [System.Security.Permissions.SecurityPermission(System.Security.Permissions.SecurityAction.Demand)]
        public override void Uninstall(System.Collections.IDictionary savedState)
        {
            base.Uninstall(savedState);

            if ((bool)savedState["changedPath"])
            {
                SetPath(RemovePath(GetPath(), MyPath()));
                broadcastSettingsChanged();
            }

            if ((bool)savedState["changedRegistry"])
            {
                Registry.LocalMachine.DeleteSubKey(@"SOFTWARE\Synergex\CodeGen");
            }

            ngen(savedState, "uninstall");
        }

        [System.Security.Permissions.SecurityPermission(System.Security.Permissions.SecurityAction.Demand)]
        public override void Rollback(System.Collections.IDictionary savedState)
        {
            base.Rollback(savedState);

            if ((bool)savedState["changedPath"])
            {
                SetPath((string)savedState["previousPath"]);
                broadcastSettingsChanged();
            }

            if ((bool)savedState["changedRegistry"])
            {
                Registry.LocalMachine.DeleteSubKey(@"SOFTWARE\Synergex\CodeGen");
            }

            ngen(savedState, "uninstall");
        }

        private static string MyPath()
        {
            return System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        }

        private static RegistryKey GetPathRegKey(bool writable)
        {
            // for the user-specific path...
            //return Registry.CurrentUser.OpenSubKey("Environment", writable);

            // for the system-wide path...
            return Registry.LocalMachine.OpenSubKey(
                @"SYSTEM\CurrentControlSet\Control\Session Manager\Environment", writable);
        }

        private static void SetPath(string value)
        {
            using (RegistryKey reg = GetPathRegKey(true))
            {
                reg.SetValue("Path", value, RegistryValueKind.ExpandString);
            }
        }

        private static string GetPath()
        {
            using (RegistryKey reg = GetPathRegKey(false))
            {
                return (string)reg.GetValue("Path", "", RegistryValueOptions.DoNotExpandEnvironmentNames);
            }
        }

        private static string AddPath(string list, string item)
        {
            List<string> paths = new List<string>(list.Split(';'));

            foreach (string path in paths)
                if (string.Compare(path, item, true) == 0)
                {
                    // already present
                    return list;
                }

            paths.Add(item);
            return string.Join(";", paths.ToArray());
        }

        private static string RemovePath(string list, string item)
        {
            List<string> paths = new List<string>(list.Split(';'));

            for (int i = 0; i < paths.Count; i++)
                if (string.Compare(paths[i], item, true) == 0)
                {
                    paths.RemoveAt(i);
                    return string.Join(";", paths.ToArray());
                }

            // not present
            return list;
        }

        #region Broadcast message

        /* Declare the Win32 API for propagating the environment variable */
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SendMessageTimeout(IntPtr hWnd,int Msg,int wParam,string lParam,int fuFlags,int uTimeout,int lpdwResult);

        /* Constant to broadcast message to all windows */
        public const int HWND_BROADCAST = 0xffff;
        public const int WM_SETTINGCHANGE = 0x001A;
        public const int SMTO_NORMAL = 0x0000;
        public const int SMTO_BLOCK = 0x0001;
        public const int SMTO_ABORTIFHUNG = 0x0002;
        public const int SMTO_NOTIMEOUTIFNOTHUNG = 0x0008;

        /// <summary>
        /// Broadcasts a WM_SETTINGCHANGE message to all "top level" windows
        /// to inform them that the system environment has changed. This allows
        /// existing processes to immediately pick up the new system environment
        /// without requiring a reboot.
        /// </summary>
        private void broadcastSettingsChanged()
        {
            //Broadcast a message
            int timeout = 3000; //3 seconds per top level window
            int result = 0;
            SendMessageTimeout(
                (System.IntPtr)HWND_BROADCAST,
                WM_SETTINGCHANGE,
                0,
                "Environment",
                SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_NOTIMEOUTIFNOTHUNG, 
                timeout, 
                result);
        }

        #endregion

        [System.Security.Permissions.SecurityPermission(System.Security.Permissions.SecurityAction.Demand)]
        private void ngen(System.Collections.IDictionary savedState, string ngenCommand)
        {
            String[] argsArray;

            if (string.Compare(ngenCommand, "install", StringComparison.OrdinalIgnoreCase) == 0)
            {
                String args = Context.Parameters["NgenAssemblies"];
                if (String.IsNullOrEmpty(args))
                {
                    throw new InstallException("No arguments specified");
                }

                char[] separators = { ';' };
                argsArray = args.Split(separators);
                savedState.Add("NgenArgs", argsArray); //It is Ok to 'ngen uninstall' assemblies which were not installed
            }
            else
            {
                argsArray = (String[])savedState["NgenArgs"];
            }

            // Gets the path to the Framework directory.
            string fxPath = System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory();

            for (int i = 0; i < argsArray.Length; ++i)
            {
                string arg = argsArray[i];
                // Quotes the argument, in case it has a space in it.
                arg = "\"" + arg + "\"";

                string command = ngenCommand + " " + arg;

                ProcessStartInfo si = new ProcessStartInfo(Path.Combine(fxPath, "ngen.exe"), command);
                si.WindowStyle = ProcessWindowStyle.Hidden;

                Process p;

                try
                {
                    Context.LogMessage(">>>>" + Path.Combine(fxPath, "ngen.exe ") + command);
                    p = Process.Start(si);
                    p.WaitForExit();
                }
                catch (Exception ex)
                {
                    throw new InstallException("Failed to ngen " + arg, ex);
                }
            }
        }

    }
}
