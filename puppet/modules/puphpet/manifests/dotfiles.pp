# class puphpet::dotfiles
#
# copies dotfiles to vm
#
class puphpet::dotfiles (
    $match    = '\.[a-zA-Z0-9]*',
    $source   = 'puppet:///modules/puphpet/dot',
    $target   = '/home/vagrant/'
) {

  exec { 'dotfiles':
    command => "cp -r ${source}/${match} ${target}",
    onlyif  => "test -d ${source}",
  }

}
