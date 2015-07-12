<?php
/**
 * Created by PhpStorm.
 * User: leosjoberg
 * Date: 12/07/15
 * Time: 22:24
 */

namespace EypDevelopers\Borders;


use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Process\Process;

class ResumeCommand extends Command
{
    protected function configure()
    {
        $this->setName('wakeup')
        ->setDescription('Resume the suspended Borders machine');
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        $process = new Process('vagrant resume', realpath(__DIR__ . '/../'), array_merge($_SERVER, $_ENV), null, null);

        $process->run(function($type, $line) use ($output)
        {
            $output->write($line);
        });
    }
}