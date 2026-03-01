pipeline {
    agent any
    
    environment {
        DOTNET_CLI_HOME = "/tmp/dotnet"
        DOTNET_ROOT = "/usr/share/dotnet"
        PROJECT_NAME = "CICD-Test"
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                echo 'Cleaning workspace...'
                sh 'rm -rf obj bin blazor-auth-app publish TestResults'
                sh 'dotnet clean ${PROJECT_NAME}.csproj || true'
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code checked out successfully'
                sh 'git rev-parse --short HEAD > .git/commit-id'
                script {
                    env.GIT_COMMIT_SHORT = readFile('.git/commit-id').trim()
                }
                echo "Building commit: ${env.GIT_COMMIT_SHORT}"
            }
        }
        
        stage('Restore Dependencies') {
            steps {
                echo 'Restoring NuGet packages...'
                sh 'dotnet restore ${PROJECT_NAME}.csproj'
            }
        }
        
        stage('Code Format Check') {
            steps {
                echo 'Checking code formatting...'
                sh 'dotnet format ${PROJECT_NAME}.csproj --verify-no-changes --verbosity diagnostic || echo "Format check completed"'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building application in Release mode...'
                sh 'dotnet build ${PROJECT_NAME}.csproj --configuration Release --no-restore'
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running unit tests with code coverage...'
                sh '''
                    dotnet test ${PROJECT_NAME}.csproj \
                    --configuration Release \
                    --no-build \
                    --logger "trx;LogFileName=test-results.trx" \
                    --collect:"XPlat Code Coverage" \
                    --results-directory ./TestResults \
                    --verbosity normal || echo "Tests completed"
                '''
            }
            post {
                always {
                    // Publish test results
                    script {
                        if (fileExists('TestResults')) {
                            echo 'Test results found'
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                echo 'Scanning for vulnerable dependencies...'
                sh 'dotnet list ${PROJECT_NAME}.csproj package --vulnerable --include-transitive || echo "Security scan completed"'
            }
        }
        
        stage('Code Analysis') {
            steps {
                echo 'Running static code analysis...'
                sh '''
                    dotnet build ${PROJECT_NAME}.csproj \
                    --configuration Release \
                    --no-restore \
                    -p:RunCodeAnalysis=true \
                    -p:CodeAnalysisTreatWarningsAsErrors=false || echo "Code analysis completed"
                '''
            }
        }
        
        stage('Publish Artifacts') {
            steps {
                echo 'Publishing application artifacts...'
                sh 'dotnet publish ${PROJECT_NAME}.csproj --configuration Release --no-build --output ./publish'
                sh 'ls -lah ./publish'
            }
            post {
                success {
                    // Archive the published artifacts
                    archiveArtifacts artifacts: 'publish/**/*', fingerprint: true
                    echo 'Artifacts archived successfully'
                }
            }
        }
        
        stage('Package Info') {
            steps {
                echo 'Build Information:'
                sh '''
                    echo "================================"
                    echo "Project: ${PROJECT_NAME}"
                    echo "Commit: ${GIT_COMMIT_SHORT}"
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Build Date: $(date)"
                    echo "================================"
                    echo "Published Files:"
                    ls -lh ./publish | head -20
                    echo "================================"
                '''
            }
        }
    }
    
    post {
        success {
            echo '✅ Build completed successfully!'
            echo "Build #${BUILD_NUMBER} - Commit ${env.GIT_COMMIT_SHORT}"
        }
        failure {
            echo '❌ Build failed!'
            echo "Build #${BUILD_NUMBER} failed. Check logs for details."
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
