<?php
/**
 * Created by PhpStorm.
 * User: leosjoberg
 * Date: 12/07/15
 * Time: 22:24
 */

namespace EypDevelopers\Borders;


use Symfony\Component\Process\Process;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class InitCommand extends Command
{
    protected function configure()
    {
        $this->setName('setup')
        ->setDescription('Get your borders setup');
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        if (is_dir(borders_path())) {
            throw new \InvalidArgumentException('Borders have already been setup');
        }

        mkdir(borders_path());

        copy(__DIR__ . '/stubs/Borders.yaml', borders_path() . '/Borders.yaml');

        $output->writeln('<comment>Creating Borders.yaml file...</comment> <info>✔</info>');
        $output->writeln('<comment>Borders.yaml file created at:</comment> '.borders_path().'/Borders.yaml');
    }
}