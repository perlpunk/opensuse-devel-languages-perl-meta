use v5.42;
use experimental 'class';

class Module::OpenSUSE::Meta::Git 0.001 {
    use autodie;

    field $dir :param :reader;

    method commit_and_date () {
        local $ENV{HOME} = ''; # no local config files
        my $cmd = "git -C $dir log --pretty=format:'%H %ad' --date=short -1";
        my @out = qx{$cmd};
        my ($sha, $date) = split ' ', $out[0];
        return ($sha, $date);
    }
}
