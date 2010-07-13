package Javascript::Closure;
use 5.008008;
use strict;
use warnings;
use Carp;
use LWP::UserAgent;
our $VERSION = 0.03;

use constant {
    WHITESPACE_ONLY        =>'WHITESPACE_ONLY',
    SIMPLE_OPTIMIZATIONS   =>'SIMPLE_OPTIMIZATIONS',
    ADVANCED_OPTIMIZATIONS =>'ADVANCED_OPTIMIZATIONS',
    COMPILED_CODE          =>'compiled_code',
    WARNINGS               =>'warnings',
    ERRORS                 =>'errors',
    STATISTICS             =>'statistics',
    TEXT                   =>'text',
    JSON                   =>'json',
    XML                    =>'xml',
    CLOSURE_COMPILER_SERVICE=>'http://closure-compiler.appspot.com/compile'
};


require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(minify 
					WHITESPACE_ONLY 
					SIMPLE_OPTIMIZATIONS 
					ADVANCED_OPTIMIZATIONS 
					COMPILED_CODE 
					WARNINGS 
					ERRORS 
					STATISTICS 
					TEXT 
					JSON 
					XML
);
our %EXPORT_TAGS = (CONSTANTS => [qw(WHITESPACE_ONLY SIMPLE_OPTIMIZATIONS ADVANCED_OPTIMIZATIONS COMPILED_CODE WARNINGS ERRORS STATISTICS TEXT JSON XML)]);


sub minify {
  my %args = @_;
     
  my $output_info       = $args{output_info}       || COMPILED_CODE;
     $output_info       = _cleanup_output_info($output_info);

  my $output_format     = $args{output_format}     || TEXT;   
  my $compilation_level = $args{compilation_level} || WHITESPACE_ONLY;  

  my $js                = $args{input}             || 'var test=true;//this is a test';
  my $source            = _cleanup_code_source($js);

  my $ret    = '';

  my $ua = LWP::UserAgent->new;
     $ua->agent("closure-minifier/0.1");

  #we have some raw data here of javascript
  if($source->{string} ne ''){
     $ret.= _compile($ua,$source->{string},$output_info,$output_format,$compilation_level);
  }

  #in the mix we got some urls too
  if($source->{urls} ne ''){
     $ret.= _compile($ua,$source->{urls},$output_info,$output_format,$compilation_level);
  }
  return $ret;
 
}

sub _compile {
  my ($ua,$js,$output_info,$output_format,$compilation_level)=@_;

  # Create a request
  my $req = HTTP::Request->new(POST => CLOSURE_COMPILER_SERVICE);
  $req->content_type('application/x-www-form-urlencoded');
  $req->content("$js&$output_info&output_format=$output_format&compilation_level=$compilation_level");

  my $res = $ua->request($req);
  if ($res->is_success) {
      return $res->content;
  }
  croak 'Fail to connect to '.CLOSURE_COMPILER_SERVICE.':'.$res->is_error;

}

sub _cleanup_output_info {
   my $output_info = shift;
   if(ref($output_info) eq 'ARRAY') {
	   map { $_='output_info='.$_; } @$output_info;
	   $output_info= join '&',@$output_info;
   } 
   else {
      $output_info='output_info='.$output_info;
   }
   return $output_info;
}

sub _cleanup_code_source {
   my $code_source = shift;

   $code_source = [$code_source] if(ref($code_source) ne 'ARRAY');

   my (@str,@urls);
   foreach my $js (@$code_source) {

       if($js!~m{^http://}){
           $js =~ s/(\W)/"%" . unpack("H2", $1)/ge;#urlencode 
           push @str,'js_code='.$js;
       }
       else {
           push @urls,'code_url='.$js;
       }
   }

   return {
	   string => @str > 0 ? join '&',@str  :'',
	   urls   => @urls> 0 ? join '&',@urls :'',
   };
}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

Javascript::Closure - compress your javascript code using Google online service of Closure Compiler 

=head1 VERSION

0.03

=head1 SYNOPSIS


	#nothing is imported by default
    use Javascript::Closure qw(minify); 

    #you can import the constants too
    use Javascript::Closure qw(minify :CONSTANTS);

    #open a file
    open (FILE,'<','jscript.js') or die $!;
    my @lines = <FILE>;
    close FILE;
	
    #compress the code. most of the time it will be all you need!
    my $compressed   = minify(input=>join('',@lines));
    
    #output the result in another file
    open FILE,'>','closure-jscript.js' or die $!;
    print FILE $compressed;
    close FILE;

    #further tweaking of the result is possible though...

    #you can add options:
    my $compressed = minify(input            => [$string,'http://www.domain.com/my.js',$string2,'http://www.domain2.com/my2.js'],
                            output_format    => Javascript::Closure::XML,
                            output_info      => Javascript::Closure::STATISTICS,
                            compilation_level=> Javascript::Closure::ADVANCED_OPTIMIZATIONS
    );


     my $compressed = minify(input            => $string,
                            output_format    => XML,
                            output_info      => STATISTICS,
                            compilation_level=> ADVANCED_OPTIMIZATIONS
    );  

    #specifiy multiple output_info
    use Javascript::Closure qw(minify :CONSTANTS);

     my $compressed = minify(input            => $string,
                            output_format    => JSON,
                            output_info      => [STATISTICS WARNINGS COMPILED_CODE],
                            compilation_level=> SIMPLE_OPTIMIZATIONS
    ); 

=head1 DESCRIPTION

This package allows you to compress your javascript code by using the online service of Closure Compiler offered by Google
via a REST API. 
See L<http://closure-compiler.appspot.com/> for further information.


=head1 MOTIVATION

Needed a package to encapsulate a coherent API for a future Javascript::Minifier::Any package.

=head1 ADVANTAGES

Gives you access to the closure compression algo with an unified API.

=head1  CONSTANTS

=item B<compilation level related>

 - WHITESPACE_ONLY
   remove space and comments from javascript code.

 - SIMPLE_OPTIMIZATIONS
   compress the code by renaming local variables

 - ADVANCED_OPTIMIZATIONS
   compress all local variables, do some clever stripping down of the code (unused functions are removed) 
   but you need to setup external references to do it properly.

See L<http://code.google.com/intl/ja/closure/compiler/docs/api-tutorial3.html> for further information.

=item B<output format related>

 - XML
   return the output in XML format with the information set with your output_info settings

 - JSON
   return the output in JSON format with the information set with your output_info settings

 - TEXT
   return the output in raw text format with the information set with your output_info settings

See L<http://code.google.com/intl/ja/closure/compiler/docs/api-ref.html#out> for further information.

=item B<output info related>

 - COMPILED_CODE
   return only the raw compressed javascript source code.

 - WARNINGS
   return any warnings found by the Closure Compiler (ie,code after a return statement)

 - ERRORS
   return any errors in your javascript code found by the Closure Compiler

 - STATISTICS
   return some statistics about the compilation process (original file size, compressed file size, time,etc)

See L<http://code.google.com/intl/ja/closure/compiler/docs/api-ref.html#output_info> for further information.

=over 

=head1  SUBROUTINES/METHODS

=over 

=item B<minify(input=>scalar||array ref,compilation_level=>scalar,output_info=>scalar,output_format=>scalar)>

Takes an hash with the following parameters:

 - input: scalar or array ref

The input accepts either a scalar containing the javascript code to be parsed or an url to grap the javascript.
You can also use an array reference containing multiple urls or raw source code (input=>[$string,'http://www.domain.com/f.js']). 
If you combine both urls and raw source code, minify will create 2 queries to the service.


Other parameters are options set by default:

 - compilation_level:scalar

    WHITESPACE_ONLY
    SIMPLE_OPTIMIZATIONS (default)
    ADVANCED_OPTIMIZATIONS
    
 - output_info: scalar or array ref

     COMPILED_CODE (default)
     WARNINGS
     ERRORS
     STATISTICS
     
 - output_format:scalar
     TEXT (default)
     JSON
     XML

minify returns the compressed version of the javascript code as a scalar.
The package does not send back a JSON or XML object. Only the raw string from the service.

=back

=head1 DIAGNOSTICS

=over

=item C<< Fail to connect to http://closure-compiler.appspot.com/compile:... >>

The module could not connect and successfully compress your javascript. 
See the detail error to get a hint.


=back

=head1 TODO

=over

=item B<optional parameters>

none of the following optional parameters are supported:

 - warning_level
 - use_closure_library
 - formatting
 - output_file_name
 - exclude_default_externs
 - externs_url
 - js_externs


=back


=head1  SEE ALSO

=item B<other related modules>

L<Javascript::Minifier>
L<Javascript::Packer>
L<JavaScript::Minifier::XS>
L<http://closure-compiler.appspot.com/>

=back

=head1  CONFIGURATION AND ENVIRONMENT

none


=head1  DEPENDENCIES

L<LWP::UserAgent>

=head1  INCOMPATIBILITIES

none

=head1 BUGS AND LIMITATIONS

If you do me the favor to _use_ this module and find a bug, please email me
i will try to do my best to fix it (patches welcome)!

=head1 AUTHOR

shiriru E<lt>shiriru0111[arobas]hotmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
