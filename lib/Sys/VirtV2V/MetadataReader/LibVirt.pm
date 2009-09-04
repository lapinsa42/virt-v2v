# Sys::VirtV2V::MetadataReader::LibVirt
# Copyright (C) 2009 Red Hat Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

package Sys::VirtV2V::MetadataReader::LibVirt;

use strict;
use warnings;

use XML::DOM;

use Locale::TextDomain 'virt-v2v';

=pod

=head1 NAME

Sys::VirtV2V::MetadataReader::LibVirt - Read libvirt metadata from libvirtd

=head1 SYNOPSIS

 use Sys::VirtV2V::MetadataReader;

 $reader = Sys::VirtV2V::MetadataReader->get_instance("libvirt);
 $dom = $reader->get_dom($vmm);

=head1 DESCRIPTION

Sys::VirtV2V::MetadataReader::LibVirt is a backend for
Sys::VirtV2V::MetadataReader which reads a guest's libvirt XML directly from a
libvirt connection.

See L<Sys::VirtV2V::MetadataReader> for a description of its exported
methods.

=cut

use constant NAME => "libvirt";

sub new
{
    my $class = shift;

    my $config = shift; # Unused in this backend

    my $self = {};

    bless($self, $class);

    return $self;
}

sub get_name
{
    my $class = shift;

    return NAME;
}

sub is_configured
{
    my $self = shift;

    return 1;
}

sub handle_arguments
{
    my $self = shift;

    # The first argument is the name of a libvirt domain
    $self->{name} = shift;

    # Warn if we were given more than 1 argument
    if(scalar(@_) > 0) {
        print STDERR "Warning: ".NAME." only takes a single filename.\n";
    }
}

sub get_dom
{
    my $self = shift;

    my ($vmm) = shift;

    # Lookup the domain
    my $domain;
    eval {
        $domain = $vmm->get_domain_by_name($self->{name});
    };

    # Warn and exit if we didn't find it
    unless($domain) {
        print STDERR __x("{name} isn't a valid guest name",
                         name => $self->{name})."\n";
        return undef;
    }

    my $xml = $domain->get_xml_description();
    return new XML::DOM::Parser->parse($xml);
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Red Hat Inc.

=head1 LICENSE

Please see the file COPYING.LIB for the full license.

=head1 SEE ALSO

L<Sys::VirtV2V::MetadataReader(3)>,
L<virt-v2v(1)>,
L<virt-snapshot(1)>,
L<http://libguestfs.org/>.

=cut