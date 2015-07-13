<?php
/**
 * Created by PhpStorm.
 * User: leosjoberg
 * Date: 12/07/15
 * Time: 22:24
 */

namespace EypDevelopers\Europa;


use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Process\Process;

class SshCommand extends Command
{
    protected function configure()
    {
        $this->setName('ssh')
        ->setDescription('SSH into the Europa machine');
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        chdir(__DIR__.'/../');
        passthru($this->setEnvironmentCommand() . ' vagrant ssh');
    }

    protected function setEnvironmentCommand()
    {
        if ($this->isWindows()) {
            return 'SET VAGRANT_DOTFILE_PATH='.$_ENV['VAGRANT_DOTFILE_PATH'].' &&';
        }
        return 'VAGRANT_DOTFILE_PATH="'.$_ENV['VAGRANT_DOTFILE_PATH'].'"';
    }

    protected function isWindows()
    {
        return strpos(strtoupper(PHP_OS), 'WIN') === 0;
    }
}