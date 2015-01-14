Binky
=====

Binky is an email autoresponder.  You send it a message and it replies.  Typically this is for getting web pages.  Currently, the program supports sending web pages, files on the web, local files, and text files to the user in a variety of formats. It could be extended to get current weather information, give a system's status, act like an FTP server, or run scriptable telnet sessions.

Binky requires a server that has perl installed and a few modules.  It's been a very long time since Binky was alive.  It could be terribly difficult to resuscitate this piece of software, but you are certainly welcome to try.


Project State
-------------

**Abandoned Project**

Binky was always designed to be open source. It works fairly well now, but I think it could use a complete rewrite. I don't have the ambition nor the time to do that. So, in the hopes that someone finds this software useful, I am putting it online. Initially it was released under GPL on SourceForge, but this version on GitHub is public domain.  (I'm the only committer, so it's ok for me to do that.) The only support I will give for this system is in the 'docs' directory. It's been a while since I have done anything with this program, so I won't really be of any help since I will need to re-learn what I did years ago.


System Requirements
-------------------

I have only tested Binky on a Pentium 60, running Debian Linux with Perl 5 and several additional Perl modules. The only working mailer I know of is qmail, but it will likely work with sendmail or another MTA.

Configuration and data are all stored in files. In fact, a custom-written text-based database module holds all of the user data. I admit that the coding isn't up to snuff with the Perl mongers, but hey, I tried. The text-based database module is the major drawback -- it is quite slow when it gets bigger.


License
-------

This project is abandoned and everything is considered PUBLIC DOMAIN.  Use it for any purpose you like, without restriction.
