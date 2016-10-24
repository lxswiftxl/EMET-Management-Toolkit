function Generate-EmetEvent()
{
    Param(
    [Parameter(Mandatory="true",
               ParameterSetName="Stock",Position=0)]
    [switch]$Stock,

    [Parameter(Mandatory="true",
               ParameterSetName="Live",Position=0)]
    [switch]$Live,

    [Parameter(Mandatory="true",
               ParameterSetName="Live")]
    [string]$ProcessToEmulate,
    
    [int]$NumberOfEventsToGenerate = 1
    )

    $Mitigation = "Caller"
    $Process = (Get-Process -Name $ProcessToEmulate)[0]
    $ProcessName = $Process.path | split-path -Leaf
    $ProcessFullName = $Process.path
    $ProcessUser = $Process.StartInfo.Environment["USERNAME"]
    $ProcessUserDomain = $Process.StartInfo.Environment["USERDOMAIN"]
    $ProcessPid = "0x" + ('{0:x}' -f $Process.Id).ToUpper() + " (" + $Process.Id + ")"

    $LiveEvent = "EMET detected $Mitigation mitigation and will close the application: $ProcessName

    EAF check failed:
      Application 	: $ProcessFullName
      User Name 	: $ProcessUserDomain\$ProcessUser
      Session ID 	: 1
      PID 		: $ProcessPid
      TID 		: $ProcessPid
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
    "

    $netidmgr_EAF = "EMET detected EAF mitigation and will close the application: netidmgr.exe

    EAF check failed:
      Application 	: C:\Program Files (x86)\MIT\Kerberos\bin\netidmgr.exe
      User Name 	: WIN\ihcho
      Session ID 	: 1
      PID 		: 0x14AC (5292)
      TID 		: 0x14E4 (5348)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
    "

    $chrome_EAF = "EMET detected EAF mitigation and will close the application: chrome.exe

    EAF check failed:
      Application 	: C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
      User Name 	: WIN\ihcho
      Session ID 	: 1
      PID 		: 0x14CC (5324)
      TID 		: 0x1030 (4144)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
    "

    $pidgin_EAF = "EMET detected EAF mitigation and will close the application: pidgin.exe

    EAF check failed:
      Application 	: C:\Program Files (x86)\Pidgin\pidgin.exe
      User Name 	: WIN\ihcho
      Session ID 	: 1
      PID 		: 0x218C (8588)
      TID 		: 0x21D4 (8660)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
    "

    $plugin_container_EAF = "EMET detected EAF mitigation and will close the application: plugin-container.exe

    EAF check failed:
      Application 	: C:\Program Files (x86)\Mozilla Firefox\plugin-container.exe
      User Name 	: WIN\ihcho
      Session ID 	: 1
      PID 		: 0x9A8 (2472)
      TID 		: 0x3D0 (976)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
    "

    $Acrobat_EAF = "EMET detected EAF mitigation and will close the application: Acrobat.exe

    EAF check failed:
      Application 	: C:\Program Files (x86)\Adobe\Acrobat 11.0\Acrobat\Acrobat.exe
      User Name 	: WIN\ihcho
      Session ID 	: 1
      PID 		: 0x1B68 (7016)
      TID 		: 0x1B70 (7024)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
      Input file 	: D:\Desktop\TechSmith Online Store - Invoice.pdf
      MD5 		: 0x0964BAFE204112834ADFC2C4189668F7
      SHA1 		: 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709
    "

    $Acrobat_EAF_2 = "EMET detected EAF mitigation and will close the application: Acrobat.exe

    EAF check failed:
      Application 	: C:\Program Files (x86)\Adobe\Acrobat 11.0\Acrobat\Acrobat.exe
      User Name 	: WIN\ihcho
      Session ID 	: 1
      PID 		: 0x133C (4924)
      TID 		: 0x1AD8 (6872)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
      Input file 	: D:\Desktop\Quote Summary_710289730.pdf
      MD5 		: 0x3D756EA47CC1C213677F1124A2905924
      SHA1 		: 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709
    "

    $Acrobat_EAF_3 = "EMET detected EAF mitigation and will close the application: Acrobat.exe

    EAF check failed:
      Application 	: C:\Program Files (x86)\Adobe\Acrobat 11.0\Acrobat\Acrobat.exe
      User Name 	: WIN\ihcho
      Session ID 	: 1
      PID 		: 0x2264 (8804)
      TID 		: 0x2734 (10036)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x71B0036C
      Mem Address 	: 0x00000000
      Input file 	: C:\Users\ihcho.WIN\AppData\Local\Microsoft\Windows\INetCache\Content.Outlook\NXX238SZ\2202529940.pdf
      MD5 		: 0x303847B75FD2F5E37F69CDC51B46E9D6
      SHA1 		: 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709
    "

    $chrome_Caller = "EMET detected Caller mitigation and will close the application: chrome.exe

    Caller check failed:
      Application 	: C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
      User Name 	: AS-RFCS-126\systems
      Session ID 	: 1
      PID 		: 0x1178 (4472)
      TID 		: 0x1164 (4452)
      API Name 	: ntdll.NtCreateFile
      ReturnAddress 	: 0x745619BF
      CalledAddress 	: 0x77C900F4
      TargetAddress 	: 0x37C702A4
      StackPtr 	: 0x00C8DC20
    "

    $IEXPLORER_Caller = "EMET detected Caller mitigation and will close the application: IEXPLORE.EXE

    Caller check failed:
      Application 	: C:\Program Files (x86)\Internet Explorer\IEXPLORE.EXE
      User Name 	: CO-PC-30442\sysgroup
      Session ID 	: 1
      PID 		: 0x4A0 (1184)
      TID 		: 0x1654 (5716)
      API Name 	: kernel32.LoadLibraryExW
      ReturnAddress 	: 0x709DA171
      CalledAddress 	: 0x76574915
      TargetAddress 	: 0x709D4F30
      StackPtr 	: 0x00DCECB8
    "

    $IEXPLORER_DEP = "EMET detected DEP mitigation and will close the application: IEXPLORE.EXE

    DEP check failed:
      Application 	: C:\Program Files (x86)\Internet Explorer\IEXPLORE.EXE
      User Name 	: AD-725-LISACHAD\Lisa
      Session ID 	: 1
      PID 		: 0x1644 (5700)
      TID 		: 0x16D0 (5840)
      Module 	: N/A
      Mod Base 	: 0x00000000
      Mod Address 	: 0x621C8F33
      Mem Address 	: 0x621C8F33
    "

    # List of all messages for EMET logs above
    #$IEXPLORER_DEP, $IEXPLORER_Caller, $chrome_Caller, $chrome_EAF, $Acrobat_EAF_3, $Acrobat_EAF_2, $Acrobat_EAF, $plugin_container_EAF, $pidgin_EAF,  $netidmgr_EAF

    $list_of_messages = @($IEXPLORER_DEP,
                          $IEXPLORER_Caller,
                          $chrome_Caller,
                          $chrome_EAF,
                          $Acrobat_EAF_3,
                          $Acrobat_EAF_2,
                          $Acrobat_EAF,
                          $plugin_container_EAF,
                          $pidgin_EAF,
                          $netidmgr_EAF)
    
    if ($Live)
    {
        $list_of_messages = $LiveEvent
    }

    $counter = 0
    while ($counter -lt $NumberOfEventsToGenerate)
    {
        foreach ($message in $list_of_messages)
        {
            Write-EventLog -LogName Application -Source EMET -EntryType Error -EventId 02 -Category 0 -Message $message
        }
        $counter += 1
    }
}