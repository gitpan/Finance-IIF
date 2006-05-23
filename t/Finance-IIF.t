#!/usr/bin/perl
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Finance-IIF.t'

use strict;
use warnings;
use Test::More tests => 29;

BEGIN { use_ok("Finance::IIF") or exit; }

my $package  = "Finance::IIF";
my $testfile = "t/sample.iif";

{    # new
    can_ok( $package, qw(new) );

    my $obj = $package->new;
    isa_ok( $obj, $package );

    is( $obj->{debug}, 0, "default debug value" );
    is( $obj->{field_separator}, "\t", "default field separator" );
    is( $obj->{input_record_separator}, $/, "default input record separator" );
    is( $obj->{output_record_separator}, $\,
        "default output record separator" );

    $obj = $package->new(
        debug                   => 1,
        field_separator         => ",",
        input_record_separator  => "X\rX\n",
        output_record_separator => "X\rX\n"
    );

    is( $obj->{debug},           1,   "custom debug value" );
    is( $obj->{field_separator}, ",", "custom field separator" );
    is( $obj->{input_record_separator},
        "X\rX\n", "custom input record separator" );
    is( $obj->{output_record_separator},
        "X\rX\n", "custom output record separator" );
}

{    # file
    can_ok( $package, qw(file) );

    my $obj = $package->new;

    is( $obj->file, undef, "file undef by default" );
    is( $obj->file($testfile), $testfile, "file with one arg" );
    is( $obj->file( $testfile, "<" ), $testfile, "file with two args" );

    $obj = $package->new( file => $testfile );
    is( $obj->file, $testfile, "new with scalar file argument" );

    $obj = $package->new( file => [ $testfile, "<:crlf" ] );
    is( $obj->file, $testfile, "new with arrayref file argument" );

    is_deeply( [ $obj->file( 1, 2 ) ], [ 1, 2 ], "file returns list" );
}

{    # croak checks for: _filehandle next _getline reset close
    my @methods = qw(_filehandle next _getline reset close);
    can_ok( $package, @methods );

    foreach my $method (@methods) {
        my $obj = $package->new;
        eval { $obj->$method };
        like(
            $@,
            qr/^No filehandle available/,
            "$method without a filehandle croaks"
        );
    }
}

{    # open
    can_ok( $package, qw(open) );

    my $obj = $package->new;
    eval { $obj->open };
    like( $@, qr/^No file specified/, "open without a file croaks" );

    $obj = $package->new;
    is( ref $obj->open($testfile), "IO::File", "open returns IO::File object" );
}

{    # _parseline
    can_ok( $package, qw(_parseline) );
}

{    # _warning
    can_ok( $package, qw(_warning) );
}
