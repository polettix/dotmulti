Alas, dotCloud exported its pricing and there seems to be a limit
of two services per free account. Many "game" projects actually require
more services, so it can be useful to have a central repository for
the configurations of the different accounts... just to play with.

To use it you will need a dotcloud account with the possibility to
create one application with 2 services (substitute "yourapp" with the name of your application):

    $ git clone git://github.com/polettix/dotmulti.git
    $ cd dotmulti
    $ dotcloud create yourapp
    $ dotcloud push yourapp

First of all you have to create an account into the database. The password
is not saved in plaintext but after and md5sum, so you have to manage this
on the command line for the moment:

    $ echo -n 'your-password' | md5sum
    b2bdfbbae9c3f49ac4ba0bfd8ba0ca6e  -

Take the initial sequence of characters, this will be your password.

    $ dotcloud info yourapp.data  # to get redis-password
      ...
      config:
          redis_password: <redis-password>
      ...
    $ dotcloud run yourapp.data -- redis-cli
    # redis-cli
    redis> auth <redis-password>
    OK
    redis> set user:your-username:password b2bdfbbae9c3f49ac4ba0bfd8ba0ca6e

Now you can connect:

    $ dotcloud url yourapp.www
    www: http://yourapp-youraccount.dotcloud.com/

The application is set to redirect to https before allowing you to do anything, so the Basic HTTP authentication should be OK. All the URIs that you have
to use must start with https, anyway, otherwise you will be redirected.

When prompted, you have to provide the password that you saved into the database ('your-password' in the example above). Use the form on the right to add the environment.json/environment.yml files of your applications in all
your accounts. You can then get them back as 'application/json' with the
following URIs:

    # list of applications saved
    https://yourapp-youraccount.dotcloud.com/applications

    # all the configurations of all the applications
    https://yourapp-youraccount.dotcloud.com/configurations

    # application-specific
    https://yourapp-youraccount.dotcloud.com/configuration/application-name

If you do not have md5sum in your system, you can connect to the following
URI in your application:

    # application-specific
    https://yourapp-youraccount.dotcloud.com/public/password/your-password

and get the password.

Of course... all the procedure above is UNTESTED!!!
