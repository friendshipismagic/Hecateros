<h1 align=center>Hekateros <img src="https://img.shields.io/github/tag/friendshipismagic/hekateros.svg"> / <img src="cycle-beta-yellow.svg"></h1>

![Logo](Hekateros.svg)

>God of the *hekateris*, a dance which involves quickly moving hands

Hekateros sits on an IRC channel and parses the http links that are posted on it, then displays them on a web interface.

You can find a live version on the [RezoSup](https://chat.rezosup.org/) on #Ekta-bots

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Key features](#key-features)
- [Administration](#administration)
- [Deployment](#deployment)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Key features

1. A filter system that you can turn on and off at runtime for both tags and URLs
2. Good resilience, by taking advantage of the Erlang/OTP runtime.
3. No external DBMS. It uses SQLite3 as an on-disk storage. Backup your data as easily as `scp`.
4. A responsive web interface.


## Administration

Hekateros provides an administration interface from IRC. You must be a registered administrator in the bot's system to operate it.

When you first invite Hekateros on an channel, it will send you a private message with a summary of its commands. Hekateros' underlying authentication
system is backed by the network's Services (NickServ). Other administrators will need to be registered to NickServ so they can be registered as
administrators.  


## Deployment

You can find an Ansible playbook in the `deploy` fodler with the template and configuration files. The inventory must export the `public_interface` variable, which is the address Nginx will be listening on.


## License

The code is licensed under the [MIT](LICENSE.txt) license.  
The Hekateros logo is licensed under the [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) license.
