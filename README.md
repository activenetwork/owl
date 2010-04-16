= Owl

There are plenty of site monitoring tools out there, but we were looking for something a
little different. A way to determine, at a glance, the health of all of our servers. That's
where Owl comes in.

== Terminology

Owl centers around the concept of a "watch." A watch is one webpage that you want to monitor.
Multiple watches roll up under a "site." For example you might have two watches:

* http://example.com/home
* http://example.com/login

These could both live under a site named "Example.com" so that you easily monitor just certain
groups of servers instead of all of them at once.

== Usage

Owl is comprised of two parts: the front-facing website and a backend process called Mouse
that constantly requests all the watches you have defined. The response times, status codes,
etc. are saved to a database and used to compile the info for the front-facing site.

If you enable alerts so that you can be notified if a watch does not response as expected,
you will also run Delayed Job in the background to send you these alerts.

=== Frontend

The Owl frontend is a Ruby on Rails website. Before you start it you will need to build the
database and seed it with data. Copy @config/database_sample.yml@ to @config/database.yml@ 
and change the development/production settings to suit your environment. Next, run a couple
of rake tasks to prepare the database:
  
  rake db:migrate
  rake db:seed
  
You can now start the frontend:

  script/server
  
And then start Mouse:

  lib/mouse/bin/mouse -i 30
  
This tells Mouse to start crawling your watches every 30 seconds (you can call Mouse with
-h to see available options).

Now browse to Owl and start adding sites and watches: http://localhost:3000

=== Alerts

Owl currently supports alerts via Twitter and Instant Message. You will need to start
Delayed Job so that it can pull messages off the job queue and send them to you. See
@lib/mouse/alerts@ for the job classes. These are configured in the job files themselves
so simply modify them to use your own Twitter and IM account connection info.

SMS and Email notifications are stubbed out but have not been built as of this writing.
