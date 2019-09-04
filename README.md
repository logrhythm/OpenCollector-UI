![GUI for LogRhythm Open-Collector](Images/Banner.png "GUI for LogRhythm Open-Collector")
# GUI for LogRhythm Open-Collector (OpenCollector-UI)

Hi there,

This project, is aimed at creating an easy to use Graphical User Interface for LogRhythm Open-Collector.

LogRhythm Open-Collector runs on CoreOS, CentOS (an under RHEL if approved by Product Management), and relies on several components to run (Docker, etc...).
This GUI is designed to make both **installation**, **monitoring** and **managing** the Open-Collector stack **easy**, as well as authoring and testing custom Filters and Transform in the same App.

The GUI project englobes several sub projects:
- A Command Line tool (```OCHelper.sh```) to do actions on the Open-Collector machine from the CLI. Inputing and Outputing in strict formats (Raw or JSON), so be easily used as a point of entry for a user as well as other tools and UIs. See this as the API back-end.
- A PowerShell based GUI (```OC_UI-v?.?.ps1```) for Windows -*and Mac if install PowerShell there*- that relies on the CLI tool above
- A Menu based UI, all in text to be used on the CLI
- A Web based interface for everybody, that will rely on the CLI tool too.

### Stack:
The whole stack is planed to be like this:
![Open-Collector UI Stack](Images/OpenCollectorUI-Stack.png "Open-Collector UI Stack")

### Status: 
*(as of 2019-09-04)*
- ![Done](Images/Done.png "Done") CLI tool (```OCHelper.sh```)
- ![Done](Images/Done.png "Done") PowerShell GUI (```OC_UI-v?.?.ps1```)
- ![Planned](Images/Planned.png "Planned") Text/Menu based UI
- ![Planned](Images/Planned.png "Planned")Web UI

### Screenshots: 
*(as of 2019-09-04)*
#### - PowerShell based GUI (```OC_UI-v1.0.ps1```): 
![Welcome Screen](Images/Screenshots/OC_UI_v1.0/1.Welcome.png "Welcome Screen") 
![Login Screen](Images/Screenshots/OC_UI_v1.0/2.Login.png "Login Screen") 
![Login Screen](Images/Screenshots/OC_UI_v1.0/3.LoginDone.png "Login Screen") 
![Status Screen](Images/Screenshots/OC_UI_v1.0/4.Status.png "Status Screen") 
![Install Screen](Images/Screenshots/OC_UI_v1.0/5.Install.png "Install Screen") 
![Install Screen with Advanced and Options rolled out](Images/Screenshots/OC_UI_v1.0/6.InstallAdvancedOptions.png "Install Screen with Advanced and Options rolled out") 
![Pipelines Screen](Images/Screenshots/OC_UI_v1.0/7.Pipelines.png "Pipelines Screen") 

### Download:
Latest versions:
- PowerShell based GUI (```OC_UI-v1.0.ps1```)
  - Version 1.0 : [Download](Releases/Release-OC_UI-v1.0.20190904.zip) [:floppy_disk:](Releases/Release-OC_UI-v1.0.20190904.zip)

Contact me if you would like to be involded.

Cheers,

 Tony

