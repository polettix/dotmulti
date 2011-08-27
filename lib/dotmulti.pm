package dotmulti;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Dancer;
use Dancer::Plugin::FlashNote qw< flash >;
use File::Slurp qw< read_file >;
use Redis;
use MIME::Base64 qw< decode_base64 >;
use Digest::MD5 qw< md5_hex >;

before sub {
   request->path_info('/public/tohttps')
      unless lc(request()->header('x-forwarded-protocol')) eq 'https';
};

sub check_credentials {
   my ($authorization) = @_;
   return undef unless defined $authorization;
   my ($encoded) = $authorization =~ /\A \s* Basic \s+ (\S+) \z/mxs
      or return undef;
   my ($username, $password) = split /:/, decode_base64($encoded), 2;
   my $saved_password = password_for($username)
      or return undef;
   return $saved_password eq md5_hex($password);
}

before sub {
   request->path_info('/unauthorized')
      unless request->path_info() =~ m{\A /public/ }mxs
         || check_credentials(request->header('authorization'));
};

sub https_base {
   my $base = request()->base();
   $base =~ s/\Ahttp:/https:/imxs;
   return $base;
}

any [ qw< head get post > ] => '/public/tohttps' => sub {
   redirect https_base();
};

get '/unauthorized' => sub {
   header('WWW-Authenticate' => 'Basic realm="dot MULTI Cloud"');
   status 401;
   return 'Authorization Required';
};

get '/applications' => sub {
   return _json(applications => scalar(applications()));
};
get '/configurations' => sub {
   return _json(configuration_for(applications()));
};
get '/configuration/:application' => sub {
   return _json(configuration_for(params->{application}));
};

get '/' => \&get_index;
post '/' => sub {
   my ($application, $configuration) =
     @{params()}{qw< application configuration >};
   set_configuration($application, $configuration);
   redirect https_base();
};

sub get_index {
   template 'index', {applications => scalar(applications()), https_base => https_base() };
}

{
   my $config;

   sub get_dotcloud_config {
      if (!defined $config) {
         my $filename = shift || '/home/dotcloud/environment.json';
         my $config_text = read_file($filename);
         $config = from_json($config_text);    # from_json from Dancer!
      }
      return $config;
   } ## end sub get_dotcloud_config
}

sub redis {
   my $config = get_dotcloud_config();
   my ($password, $hostname, $port) =
     map { $config->{'DOTCLOUD_DATA_REDIS_' . $_} }
     qw< PASSWORD HOST PORT >;

   my $redis = Redis->new(server => "$hostname:$port");
   $redis->auth($password);
   return $redis;
} ## end sub redis

sub _json {
   content_type 'application/json; charset=utf-8';
   return to_json({@_});
}

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

sub set_configuration {
   my ($application, $configuration) = @_;
   my $redis = redis();
   $redis->set("application:$application:configuration",
      $configuration);
   $redis->sadd("applications", $application);
}

sub configuration_for {
   my $redis = redis();
   return _hash(
      map {
         $_ => $redis->get("application:$_:configuration");
        } @_
   );
} ## end sub configuration_for

sub password_for {
   my ($username) = @_;
   $username =~ s{[^\w-]+}{}gmxs;
   return redis()->get("user:$username:password");
}

1;
__END__

