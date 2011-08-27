package dotmulti;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Dancer;
use Dancer::Plugin::FlashNote qw< flash >;
use File::Slurp qw< read_file >;
use Redis;

sub _json {
   content_type 'application/json; charset=utf-8';
   return to_json({@_});
}

get '/applications' => sub {
   return _json(applications => scalar(applications()));
};
get '/services/:application' => sub {
   my $application = params->{application};
   return _json(
      application => $application,
      services    => scalar(services($application))
   );
};
get '/configuration/:application' => sub {
   my $application = params->{application};
   my @params      = $application;
   if ($application =~ /(.*^) \. (.*)/mxs) {
      @params = ($1, $2);
   }
   return _json(configuration_for(@params));
};
get '/configuration/:application/:service' => sub {
   return _json(configuration_for(@{params()}{qw< application service >}));
};

get '/' => \&get_index;

post '/configuration' => sub {
   my ($application, $service, $configuration) =
     @{params()}{qw< application service configuration >};
   configuration_for($application, $service, $configuration);
   return get_index();   
};


sub get_index {
   template 'index', {applications => scalar(full_applications())};
}

sub get_dotcloud_config {
   if (!defined $config) {
      my $filename = shift || '/home/dotcloud/environment.json';
      my $config_text = read_file($filename);
      $config = from_json($config_text);    # from_json from Dancer!
   }
   return $config;
} ## end sub get_dotcloud_config

sub redis {
   my $config = get_dotcloud_config();
   my ($password, $hostname, $port) =
     map { $config->{'DOTCLOUD_NOSQLDB_REDIS_' . $_} }
     qw< PASSWORD HOST PORT >;

   my $redis = Redis->new(server => "$hostname:$port");
   $redis->auth($password);
   return $redis;
} ## end sub redis

sub _array {
   return @_ if wantarray();
   return [@_];
}

sub _hash {
   return @_ if wantarray();
   return {@_};
}

sub applications {
   return _array(redis()->smembers('applications'));
}

sub full_applications {
   return _hash(map {
      $_ => scalar(services_for($_));
   } applications());
}

sub services_for {
   my ($application) = @_;
   return _array(redis()->smembers("application:$application:services"));
}

sub configuration_for {
   my ($application, $service, $configuration) = @_;
   my $redis = redis();
   if (defined $configuration) {
      $redis->set("service:$application.$service:configuration",
         $configuration);
   }
   my @services =
      defined($service) ? ($service) : services_for($application);
   return _hash(map {
      my $name          = "$application.$_";
      my $configuration = $redis->get("service:$name:configuration");
      $name => $configuration;
   } @services);
} ## end sub configuration_for

1;
__END__

