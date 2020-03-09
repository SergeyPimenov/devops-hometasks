import org.sonatype.nexus.repository.config.Configuration

configuration = new Configuration(
        repositoryName: 'word-cloud-generator',
        recipeName: 'raw-hosted',
        online: true,
        attributes: [
                storage: [
                        writePolicy: 'ALLOW',
                        blobStoreName: 'default',
                        strictContentTypeValidation: false
                ]
        ]
)

repository.getRepositoryManager().create(configuration)
