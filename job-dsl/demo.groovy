pipelineJob('DSL_Demo') {

    def repo = 'https://github.com/gncalper/deneme.git'

    triggers {
        scm('*/15 * * * *')
    }

    definition {
        cpsScm {
            scm {
                git(repo, 'master', { node -> node / 'extensions' << '' } )
            }
        }
    }
}