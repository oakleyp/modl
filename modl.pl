#!/usr/bin/env perl

package Modl::Parser;

use strict; use warnings;
use Data::Dumper;

use constant GLOBAL_CONFIG => {
  BaseRestDir => 'C:/Users/op961q/Documents/Repos/UD_api/src/'
  BaseWebObjDir => 'C:/Users/op961q/Documents/Repos/UD_api/src/'
  BaseModuleDir => 'C:/Users/op961q/Documents/Repos/modules/'
};

my $RestPath = 'lib/UDServer/REST/ETS.pm';
my $WebObjPath = 'lib/M5/REST/ETS';
my $ModulePath = 'M5/REST/ETS';

my $RestModule = 'UDServer::REST::ETS';
my $BaseRestModule = 'UDServer::REST';

my $WebModule = 'ETS';
my $BaseWebModule = 'Model';
my $TargetWebModule = 'Model';

my $Module = 'M5::REST::ETS';
my $BaseModule = 'M5::REST';

my %routes = (
  '/example/:id' => {
    type => 'get',
    method => "$TargetModule#get"
  }
);

my $web_mod_instance_name = lc((split(/::/g, $WebModule))[-1]);
my $mod_instance_name = lc((split(/::/g, $Module))[-1])

my $web_mod_instantion = <<"PERL"
  my $web_mod_instance_name //= $WebModule->new(
    attuid => $self->attuid
  );
PERL
;

my $mod_instantiation = <<"PERL"
  my $mod_instance_name //= $Module->new(
    attuid => $self->attuid
  )
PERL
;

#need combinator function to create sub declarations by layer

my %web_sub_declarations = (
  get => {
    declare = sub {
      my ($sub_name) = @_;

      <<"PERL"
        sub get {
          my (\$self, \%args) = \@_;

          
          if($web_mod_instance_name\-\>$sub_name()) {
            \$self\-\>render(json => $web_mod_instance_name\-\>value)
          } elsif ($web_mod_instance_name->error) {
            \$self\-\>render_error(msg => $web_mod_instance_name\-\>error);
          }
        }
PERL
  }
);

sub parse_config {
  #set config
}

sub parse_routes {
  #set routes
}

sub parse_instantiation {
  #set rest_mod_instantiation
    #mod_instantiation

}

sub parse_rest_functions {
  #set sub_instantiations
}

#output to perl modules, will be factored out
sub write_modules {

  #### Build Rest Module ####
  my $rest_module = ''

  #include modules
  $rest_module .= "
    package $RestModule;
    use strict; use warnings;

    use $BaseRestModule;
    use base '$BaseRestModule';
    use $WebModule;
  ";
  
  #declare routes
  $rest_module .= "
    sub declare_routes {
      my (\$class) = \@_;
  ";
  foreach(keys %routes) {
    $rest_module .= "
        \$class->$routes{$_}->{type}\-\>($_)\-\>to($routes{$_}->{method});
    ";
  }
  $rest_module .= "
    }
  ";

  #instantiate target module instance
  $rest_module .= "
    sub $web_mod_instance_name {
      my (\$self) = \@_;

      $web_mod_instantiation
    }
  ";

  #declare rest subroutines
  foreach(keys %web_sub_declarations) {
    $rest_module .= $web_sub_declarations->{declare}($_);
  }

  $rest_module .= "
    1;

    __END__
  ";

  #### Build Web Object ####
  my $web_object = '';

  #include modules
  $web_object .= "
    package $WebModule;
    use strict; use warnings;

    use '$BaseWebModule';
    use base '$BaseWebModule';
    use '$Module';
  ";

  #declare constructor
  $web_object .= "
    sub new {
      shift->SUPER::new(
        \@_
      )
    }
  ";

  #instantiate module
  $web_object .= "
    sub $mod_instance_name {
      my (\$self) = \@_;

      $mod_instantiation
    }
  ";
  

  #declare web obj subroutines
  foreach(keys %web_sub_declarations) {
    $web_object .= $web_sub_declarations->{declare}($_);
  }

  $web_obj .= "
    1;

    __END__;
  "

  #### Build Module ####
  my $module = '';

  #include modules
  $module .= "
    package $Module;
    use strict; use warnings;

    use $BaseModule;
    use base '$BaseModule';
  ";

  #declare constructor
  $module .= "
    sub new {
      shift->SUPER::new(
        \@_
      )
    }
  ";

  #declare module subroutines
  foreach(keys %web_sub_declarations) {
    $module .= $web_sub_declarations->{declare}($_);
  }

  $module .= "
    1;

    __END__
  ";
}
