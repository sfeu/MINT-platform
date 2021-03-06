![MINT Framework!](https://github.com/sfeu/MINT-platform/raw/master/client/static/images/mint/MINT-Logo-small-trans.png)

# MINT Framework Core Platform 2012 version

* http://www.multi-access.de

###  Introduction

Multimodal systems realizing a combination of speech, gesture and graphical-driven interaction are getting part of our everyday life.

Examples are in-car assistance systems or recent game consoles. Future interaction will be embedded into smart environments offering the user to choose and to combine a heterogeneous set of interaction devices and modalities based on his preferences realizing an ubiquitous and multimodal access.

This framework enables the modeling and execution of multimodal interaction interfaces for the web based on ruby and node.js and implements a server-sided synchronisation of all connected modes and media. Currently the framework considers gestures, head movements, multi touch and the mouse as input modes. The the output media is a nodeJS-based web application as well as sound based on the SDL libraries.

Building this framework is an ongoing effort and it has to be pointed out that it serves to demonstrate scientific research results and is not targeted to be applied to serve productive systems as they are several limitations that need to be solved (maybe with your help?) like for instance multi-user support and authentification.

The MINT core gem contains all basic AUI and CUI models as well as the basic infrastructure to create interactors and mappings. For presenting the user interface on a specific platform a "frontend framework" is required. For the first MINT version (2010) we used Rails 2.3 (See http://github.com/sfeu/MINT-rails). The current 2012 version uses nodeJS as the frontend framework. For initial experiments it is enough to follow the installation instructions of this document.

There is still no further documentation for the framework, but a lot of research articles about the concepts and theories of our approach have already been published and can be accessed from our project site http://www.multi-access.de .

An overview about the overall architecture and components can be found here: http://www.multi-access.de/mint-2012-framework/

#### Quick Facts

* Interactor-based modeling (Widgets) of interface elements by using state machines (see http://github.com/sfeu/MINT-statemachine ) that are designed using SCXML (http://w3c.org/scxml) and created on the fly at runtime (http://github.com/sfeu/scxml)
* Different to approaches like e.g. XHTML+Voice the mode and media synchronisation is implemented on the web server side, which enables device-spanning interactions and dynamically adding further media and modes during the interaction.
* The server side is implemented as a distributed system based on software agents and a redis database that enables to distribute arbitrary parts of the system to different machines.
* Interactors are modelled using a basic subset of SCXML (see http://github.com/sfeu/scxml )
* The platform comes with a set of abstract (modality independent) interactors (see specification here: http://www.multi-access.de/mint/aim/ )
* A monitor frontend to observe the state of all interactors and mappings during runtime
* Automatic synchronisation of an arbitrary set of connected web browsers
* Detailed model specification including SCXML-based behavior specification for all interactors
    * MINT Abstract Interactor Model http://www.multi-access.de/mint/aim/2012/20120821/
    * MINT Mapping Model http://www.multi-access.de/mint/mim/2012/20120827/
    * MINT Interaction Resource Model http://www.multi-access.de/mint/irm/2012/20120822/
* Basic constraint-driven automated layouting on the server side that calculates pixel-exact coordinates for all interface elements based on the Cassowary constraint solver (see http://github.com/sfeu/cassowary )
* Sound support

#### Limitations

* No multi-user support or authentication, if another user connects to an application the presentation of the first user is mirrored to the second one.
* The framework only runs on Ubuntu Linux and installation has only be tested for version 12.04 LTS
* We currently have only implemented a very limited set of concrete interactors with HTML/jQuery for the web based

### Changes to the initial MINT 2010 version

* We switched from Rails 2.3 / Juggernaut to NodeJS v0.8 / Socketstream v0.3 for the frontend framework since NodeJS allows a faster processing of the server-sided mode/media synchronization.
* We can offer limited multi-user support. The devices of each user get synchronized separately.
* We support Ubuntu 12.04 LTS instead of Ubuntu 10.04 LTS.
* The MINT-Debugger is no longer a separated tool. Instead, it is part of the platform and can be accessed by a web frontend.

### Requirements

* Ubuntu LTS 12.04
* Ruby 1.9
* NodeJS 0.8
* libSDL (MINT-sdl for sound support)
* libCassowary (for constraint solver)
* libMagick (for layouting)
* several gems managed by bundler

### Installation

The following instructions work only with Ubuntu 12.04 - we have chosen this release because it is an officially long-term supported release (LTS).

* Install ruby 1.9.3 on your Ubuntu 12.04 machine and set a symlink
  
 sudo apt-get install ruby1.9.3

* Install redis-server 2.2.11

 sudo apt-get install redis-server

* prevent installation of docs for all depended gems (optional - but this will save you a lot of time)

include into file .gemrc in home folder  
 
 gem: --no-ri --no-rdoc

* install latest stable git

 sudo gem install bundler
 sudo apt-get install git-core

* Install node.js 0.8 and the node package manager

 sudo add-apt-repository ppa:chris-lea/node.js
 sudo aptitude update
 sudo apt-get install nodejs npm

* install native library dependencies that some gems like eventmachine, SDL or Magick or our framework requires and a working C compiler to compile them

 sudo apt-get install build-essential curl libsdl-dev libsdl-mixer1.2-dev libmagickcore-dev  libmagickwand-dev
 sudo apt-get install libssl-dev libfreetype6-dev gsfonts libjpeg62-dev

* checkout statemachine, scxml, em-hiredis, dm-redis-adapter, MINT-core, MINT-platform

* Install socketstream version 0.3 and dependencies using npm

 sudo npm install -g git://github.com/socketstream/socketstream.git

* Install libcassowary by using our PPA

 sudo add-apt-repository ppa:sfeu/ppa
 sudo aptitude update
 sudo apt-get install libcassowary0

 git clone https://github.com/sfeu/MINT-platform.git

* install all the required dependencies of MINT-platform

 cd MINT-platform
 sudo bundle install
 sudo npm link socketstream
 sudo npm link redis
 sudo npm link simpletcp

* start redis-server in a separate terminal (if not already started)

 redis-server

* change to MINT-platform folder and start the MINT platform

 cd MINT-platform
 node app.js

* check if platform has been started by accessing the following url with google chrome

http://localhost:3000

* log in with user "testuser" and you should see the server-sided mouse pointer synchronization by a green dot following
  the mouse pointer

* start the example app in separate terminals

 bundle exec ruby examples/streaming_example/streaming_example.rb

* If it is still not working - write us an email.

* Now you can observe the interactors and mappings using the monitor application in a new browser tab

 http://localhost:3000/monitor

* If you have an additional windows pc available in your network, you can try out our musicsheet example
  that requires the head-tracking application (download) running on a windows pc with a web-cam.

  * start the MINT platform

    cd MINT-platform
    node app.js

  * start the Musicsheet example

    cd examples/musicsheet
    bundle exec ruby musicsheet_example.rb

  * start the Head-Tracking app on windows (http://www.multi-access.de/assets/61/HeadController_V3.zip)

    Controller.exe

  * initiate the web cam
  * calibrate the arrow to match your head tilting movements using the left/right calibration buttons
  * connect to the Ubuntu machine
  * you should now see the horizontal bar matching your head movements
  * select the tilting option on the webpage and then click on one music sheet
  * you should be able to turn the pages

* Browse the source code, read (and cite) our papers to get a basic understanding of the framework components.

* You have further ideas? Email us and help us improving the framework.

### LICENSE:

The MINT framework is  developed by Sebastian Feuerstack Copyright (C) 2010-2012 Sebastian Feuerstack

This program is  free software; you can redistribute  it and/or modify it under the terms of the  GNU Affero General Public License version 3 as published by the Free Software Foundation.
 
This program  is distributed in the  hope that it will  be useful, but WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU General Public License for more details.
 
You  should have  received a  copy of  the GNU  Affero  General Public License     along     with    this     program;     if    not,     see http://www.gnu.org/licenses or write  to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 
You can contact Sebastian Feuerstack using the contact form on his homepage http://www.feuerstack.org .
 
The  modified source  and object  code versions  of this  program must display Appropriate Legal Notices, as  required under Section 5 of the GNU Affero General Public License version 3.
 
In  accordance with  Section 7(b)  of the  GNU Affero  General Public License version  3, these Appropriate  Legal Notices must  retain the display of  the "Powered by MINT Framework" logo. If  the display of the  logo  is not  reasonably  feasible  for  technical reasons,  the Appropriate  Legal  Notices must  display the  words  "Powered by the MINT Framework".

