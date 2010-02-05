# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
Status.create([ { :id => 1, :name => 'Up', :css => 'up' },
                { :id => 2, :name => 'Down', :css => 'down' }, 
                { :id => 3, :name => 'Disabled', :css => 'disabled' }, 
                { :id => 4, :name => 'Unknown', :css => 'unknown' },
                { :id => 5, :name => 'Warning', :css => 'warning'} ])
                
ResponseCode.create([ { :id => 1, :code => 200, :name => 'OK' },
                      { :id => 2, :code => 301, :name => 'Moved Permanently' },
                      { :id => 3, :code => 302, :name => 'Found (Moved Temporarily)' },
                      { :id => 4, :code => 307, :name => 'Moved Temporarily' },
                      { :id => 5, :code => 400, :name => 'Bad Request' },
                      { :id => 6, :code => 401, :name => 'Unauthorized' },
                      { :id => 7, :code => 403, :name => 'Forbidden' },
                      { :id => 8, :code => 404, :name => 'Not Found' },
                      { :id => 9, :code => 500, :name => 'Internal Server Error' },
                      { :id => 10, :code => 502, :name => 'Bad Gateway' },
                      { :id => 11, :code => 503, :name => 'Service Unavailable' }])

AlertHandler.create([ { :id => 1, :name => 'Twitter', :class_name => 'Twitter', :description => "Will send a reply-type message (@username) to a comma-seperated list of Twitter usernames (ex: robcameron, activenotify)" },
                      { :id => 2, :name => 'Yammer', :class_name => 'Yammer', :description => "Will send a message to a comma-seperated list of Yammer usernames (ex: john-doe, m&m)" },
                      { :id => 3, :name => 'SMS', :class_name => 'SMS', :description => "Will send a text message to all phone numbers listed. Enter phone numbers without dashes, seperated by commas (ex: 8585551234,7605551234) and be sure to pick the correct carrier for each." },
                      { :id => 4, :name => 'Email', :class_name => 'Email', :description => "Will send an email to a comma-seperated list of email addresses. (ex. john@active.com, rob@active.com)" },
                      { :id => 5, :name => 'Instant Message', :class_name => 'InstantMessage', :description => 'Sends an IM to a comma-seperated list of GTalk users (ex. john@gmail.com, suzy@gmail.com) Note that all users must have accounts on <a href="http://www.google.com/talk">GTalk</a>.]' }])
                      