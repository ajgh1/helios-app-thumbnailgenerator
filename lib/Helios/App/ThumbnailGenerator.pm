package Helios::App::ThumbnailGenerator;

use 5.010;
use strict;
use warnings;
use parent 'Helios::Service';

use Image::Magick;
use Image::Magick::Thumbnail;

use Helios::Error;
use Helios::LogEntry::Levels ':all';

our $VERSION = '0.01_3460';


=head1 NAME

Helios::App::ThumbnailGenerator - Helios application to generate thumbnails for (potentially lots of) images

=head1 SYNOPSIS

 #[]

=head1 DESCRIPTION

Helios::App::ThumbnailGenerator is a small Helios application that uses 
L<Image::Magick> to generate thumbnails for images.  It's intended primary uses
are to provide a service for other applications to hand off thumbnail 
generation duties, and to distribute the workload of generating thumbnails for 
large batches of images across multiple worker processes or hosts.

Helios::App::ThumbnailGenerator uses the L<Image::Magick::Thumbnail> module, 
which uses Image::Magick to do the actual image processing behind thumbnail
generation.  The service should be able to generate a thumbnail for any image 
format supported by your installation of Image::Magick.

=head1 CONFIGURATION OPTIONS

Use the helios_config_set command or the Helios::Panoptes web admin utility to
set the following parameters for Helios::App::ThumbnailGenerator.

 original_file_path      [REQUIRED] Base path to the files to generate 
                         thumbnails for.
                         
 thumbnail_output_path   Base path to write thumbnails to.  Defaults to the 
                         value of original_file_path.
                         
 default_thumbnail_size  Default dimensions for thumbnails if the size
                         argument is not specified in the job args.  If not 
                         specified, defaults to '125x125'.

=head1 JOB ARGUMENTS

Helios::Job::ThumbnailGenerator jobs have 3 arguments:

 originalFile   [REQUIRED] Name of the file to create a thumbnail from.
                  				
 thumbnailName  Name of the thumbnail to generate.  Defaults to 
                originalFile with the size suffixed (e.g. photo_125x125.jpg).
                
 maxDimension   Size in pixels of the longest side of the thumbnail.

An example using the the default Helios::Job job argument XML format:

 <job>
 	<params>
 		<originalFile>original.jpg<originalFile>
 		<thumbnailName></thumbnailName>
 		<maxDimension>150</maxDimension>
 	</params>
 </job>

=head1 HELIOS METHODS

=head2 run($job)

=cut

sub run {
	my $self = shift;
	my $job = shift;
	my $config = $self->getConfig();
	my $args = $self->getJobArgs($job);
	
	eval {
		
		my $original  = $args->{originalFile};
		my $thumbnail = $args->{thumbnailName};
		my $max_dim   = $args->{maxDimension};

		$self->logMsg($job, LOG_INFO, "Creating thumbnail of $original (max dimension: $max_dim)");
		
		my $tdim = $self->generate_thumbnail(
			original      => $original,
			thumbnail     => $thumbnail,
			max_dimension => $max_dim,
		);

		$self->logMsg($job, LOG_INFO, "Thumbnail $thumbnail created with dimensions $tdim.");		
		$self->completedJob($job);
		1;
	} or do {
		my $E = $@;
		$self->logMsg($job, LOG_ERR, "Thumbnail generation FAILED: $E");
		$self->failedJob($job, "$E");		
	};
	
}


=head2 generate_thumbnail(%params)

Params:

=over 4

=item original

Full path to original image file.

=item thumbnail

Full path to thumbnail to generate.

=item max_dimension

The length of the longest dimension of the thumbnail image, in pixels.

=back


=cut

sub generate_thumbnail {
	my $self = shift;
	my %params = @_;
	
	# read in the original image
	my $img = Image::Magick->new();
	$img->Read($params{original});

	# create the thumbnail with its largest dimension specified by max_dimension
	my ($thumbnail, $x, $y) = Image::Magick::Thumbnail::create($img, $params{max_dimension});

	# write the thumbnail to the destination
	$thumbnail->Write($params{thumbnail});
	
	return $x.'x'.$y;
}



1;
__END__


=head1 SEE ALSO

L<Helios>, L<Image::Magick>, L<Image::Magick::Thumbnail>

=head1 AUTHOR

Andrew Johnson, E<lt>lajandy at cpan dot orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Andrew Johnson.

This library is free software; you can redistribute it and/or modify it under 
the terms of the Artistic License 2.0.  See the included LICENSE file for 
details.

=head1 WARRANTY

This software comes with no warranty of any kind.

=cut
