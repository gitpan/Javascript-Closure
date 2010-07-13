package Javascript::Closure;
use 5.008008;
use strict;
use warnings;
use Carp;
use LWP::UserAgent;
our $VERSION = 0.02;

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
our @EXPORT_OK = qw(minify);




sub minify {
  my %args = @_;
     
  my $output_info       = $args{output_info}       || COMPILED_CODE;   
  my $output_format     = $args{output_format}     || TEXT;   
  my $compilation_level = $args{compilation_level} || WHITESPACE_ONLY;  
  my $js                = $args{input}             || 'var test=true;//this is a test';
  if($js!~m{^http://}){
      $js =~ s/(\W)/"%" . unpack("H2", $1)/ge;#urlencode 
      $js='js_code='.$js;
   }
   else {
     $js='code_url='.$js;
   }

  my $ua = LWP::UserAgent->new;
     $ua->agent("closure-minifier/0.1");

  # Create a request
  my $req = HTTP::Request->new(POST => CLOSURE_COMPILER_SERVICE);
  $req->content_type('application/x-www-form-urlencoded');
  $req->content("$js&output_info=$output_info&output_format=$output_format&compilation_level=$compilation_level");

  my $res = $ua->request($req);
  if ($res->is_success) {
      return $res->content;
  }
  croak 'Fail to connect to http://closure-compiler.appspot.com/compile:'.$res->is_error;
 
}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

Javascript::Closure - compress your javascript code using Google online service of Closure Compiler 

=head1 VERSION

1.03

=head1 SYNOPSIS


    use Javascript::Closure qw(minify); 

	#open a file
	open (FILE,'<','jscript.js') or die $!;
	my @lines = <FILE>;
	close FILE;
	
	#compress the code
    my $compressed   = minify(input=>join('',@lines));
    
    #output the result in another file
	open FILE,'>','closure-jscript.js' or die $!;
	print FILE $compressed;
	close FILE;
	
	#you can add options:
	my $compressed = minify(input            => $string,
							output_format    => Javascript::Closure::XML,
							output_info      => Javascript::Closure::STATISTICS,
							compilation_level=> Javascript::Closure::ADVANCED_OPTIMIZATIONS
	);

=head1 DESCRIPTION

This package allows you to compress your javascript code by using the online service of Closure Compiler offered by Google
via a REST API. See L<http://closure-compiler.appspot.com/> for further information.


=head1 MOTIVATION

Needed a package to encapsulate a coherent API for a future Javascript::Minifier::Any package.

=head1 ADVANTAGES

Gives you access to the closure compression algo with an unified API.

=head1  SUBROUTINES/METHODS

=over 

=item B<minifier(input=> scalar,compilation_level=>scalar,output_info=>scalar,output_format=>scalar)>

Takes an hash that should contain input as a key and a javascript code a value or an url starting by http://.
If you do not supply an input, it will output a dummy compression set of data.

Other are options set by default:

 - compilation_level: 
    WHITESPACE_ONLY
    SIMPLE_OPTIMIZATIONS (default)
    ADVANCED_OPTIMIZATIONS
    
 - output_info:
     compiled_code (default)
     warnings
     errors
     statistics
     
 - output_format:
     text (default)
     json
     xml

Return the compressed version of the javascript code as a scalar by default.

=back

=head1 DIAGNOSTICS

=over

=item C<< Fail to connect to http://closure-compiler.appspot.com/compile:... >>

The module could not connect and successfully compress your javascript. 
See the detail error to get a hint.


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
