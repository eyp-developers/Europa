<?php
/**
 * Created by PhpStorm.
 * User: leosjoberg
 * Date: 12/07/15
 * Time: 22:24
 */

namespace EypDevelopers\Europa;


use Symfony\Component\Process\Process;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class InitCommand extends Command
{
    protected function configure()
    {
        $this->setName('init')
        ->setDescription('Initialise Europa');
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        if (is_dir(europa_path())) {
            throw new \InvalidArgumentException('Europa has already been setup');
        }

        mkdir(europa_path());

        copy(__DIR__ . '/stubs/Europa.yaml', europa_path() . '/Europa.yaml');

        $output->writeln('<comment>Creating Europa.yaml file...</comment> <info>✔</info>');
        $output->writeln('<comment>Europa.yaml file created at:</comment> '.europa_path().'/Europa.yaml');
    }
}