#!/bin/sh

echo 'Copying code do ~/current...'
rm -rf ~/current
cp -a . ~/current

echo 'Looking for jruby...'
which jruby || {
    echo 'Installing jruby...'
    rvm install jruby
    for JRUBY in /usr/local/rvm/bin/jruby*
    do
        [ -x $JRUBY ] && break
    done
    mkdir -p ~/bin
    ln -s $JRUBY ~/bin/jruby
}
JRUBY=~/bin/jruby

if [ -f Gemfile ]
then
    echo 'Gemfile found. Making sure that bundler is installed...'
    $JRUBY -S gem install bundler
    echo 'Checking dependencies...'
    if $JRUBY -S bundle check
    then
        true # bundler already displays a message
    else
        echo 'Installing missing dependencies...'
        $JRUBY -S bundle install
    fi
else
    echo 'No Gemfile found. No dependency will be installed automatically.'
fi

if [ -f config.ru ]
then
    echo 'config.ru found; setting up rackup job...'
    echo '#!/bin/sh' > ~/run
    echo 'cd ~/current' >> ~/run
    echo 'jruby -S rackup -p $PORT_WWW' >> ~/run
    chmod +x ~/run
fi
