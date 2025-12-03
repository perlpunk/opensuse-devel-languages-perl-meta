use v5.42;
use experimental 'class';

class Module::OpenSUSE::Meta::DB 0.001 {
    use autodie;
    use Module::OpenSUSE::Meta::Package;
    use YAML::PP qw/ DumpFile /;
    use JSON::PP qw/ encode_json /;

    field $obsdir :param :reader;
    field $exportdir :param;

    method init {
        opendir(my $dh, $obsdir);
        my @dirs = grep m/^perl-/, readdir $dh;
        closedir $dh;
        my %packages;
        for my $dir (sort @dirs) {
            say "=== $dir";
            my $pkg = Module::OpenSUSE::Meta::Package->new(db => $self, name => $dir);
            my $data = $pkg->read_meta or next;
            $packages{ $dir } = $data;
        }
        my %data = (packages => \%packages);
        my ($sha, $date) = Module::OpenSUSE::Meta::Git->new(dir => $obsdir)->commit_and_date;
        $data{last_commit} = { sha => $sha, date => $date };

        my $json = encode_json \%data;
        DumpFile "$exportdir/meta.yaml", \%data;
        open my $fh, '>', "$exportdir/meta.json";
        print $fh $json;
        close $fh;
        say "Wrote $exportdir/meta.{yaml,json}";
    }
}
