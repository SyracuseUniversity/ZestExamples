// Hello world workflow: for each greeter, one process writes a greeting and a
// second process appends " world" to it.  With the Slurm executor configured
// in nextflow.config each process invocation becomes a Slurm job.

process sayHello {
    input:
    val greeter

    output:
    path 'hello.txt'

    script:
    """
    echo -n '${greeter} says: hello' > hello.txt
    """
}

process addWorld {
    input:
    path input_file

    output:
    path 'helloworld.txt'

    script:
    """
    cat ${input_file} > helloworld.txt
    echo ' world' >> helloworld.txt
    """
}

workflow {
    def query_ch = channel.of('nextflow', 'Zest')
    sayHello(query_ch)
    addWorld(sayHello.out).view()
}
