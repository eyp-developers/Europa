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

class StatusCommand extends Command
{
    protected function configure()
    {
        $this->setName('status')
        ->setDescription('Get the status of the borders');
    }

    public function execute(InputInterface $input, OutputInterface $output)
    {
        $process = new Process('vagrant status', realpath(__DIR__ . '/../'), array_merge($_SERVER, $_ENV), null, null);

        $process->run(function($type, $line) use ($output)
        {
            $output->write($line);
        });
    }
}