# LIST OF BASIC PACKEGES TO INSTALL (via macport)

- **bat**
- **openjdk8-temurin**  
  Install wanted version of openjdk simply running this:
  ```bash
  sudo port install openjdk{VERSION}-{SUFFIX}
  ```
  Afterward set the `JAVA_HOME` environment variable in order to make the just installed openjdk version, the default one. You can achieve this adding the following to your `.bash_profile` or `.zprofile`:
  ```bash
  export JAVA_HOME="$(/usr/libexec/java_home) -v <version>" # i.e 1.8, make sure to have it installed
  ``` 

  **NOTE**: You can choose another verson of openjdk simply replacing the port version '`8`' with '`10`', '`11`', '`12`'... as you prefer appending related suffix (i.e. `temurin` for verison `8`)  
  Visit https://ports.macports.org/search/?q=openjdk&name=on for complete list.  

- **nodejs16**
- **npm8**  
  **NOTE**: It is not recommended to install packages globally. But if you do so please be aware that they won't get cleaned up when you deactivate or uninstall `npm8`. Globally installed packages will remain in
  `/opt/local/lib/node_modules/` until you manually delete them.
- **python37**        
  To make this the default Python or Python 3 (i.e., the version run by the 'python' or 'python3' commands), run one or both of:
  ```bash
  sudo port select --set python python37
  sudo port select --set python3 python37
  ```
  **NOTE**: You can choose another verson of python simply replacing the port suffix '`37`' with '`38`', '`39`', '`310`'... as you prefer.  
  Visit https://ports.macports.org/search/?q=python&name=on for complete list.
- **unrar**
- **fortune**
- **micro** 
