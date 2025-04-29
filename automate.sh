set -e 
trap 'echo "Script failed at line $LINENO"; exit 1' ERR

PROJECT_NAME="automate_web_app"
VENV_DIR="venv"
REQUIREMENTS_FILE="requirements.txt"

# Function: setup environment
setup_environment() {
  echo "Setting up environment..."
  python3 -m venv $VENV_DIR
  source $VENV_DIR/bin/activate
  echo "Installing dependencies..."
  pip install -r $REQUIREMENTS_FILE
}

# Function: Linting code
lint_code(){
  echo "Linting code...."
  black .
  flake8 || echo "⚠️ Some linting issues detected, but continuing..."
}

# Run tests
run_tests(){
  echo "Running tests..."
  PYTHONPATH=$(pwd) pytest tests/test_main.py
  if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix the issues before proceeding."
    exit 1
  else
    echo "All tests passed!"
  fi
}

# Build docker image
build_project(){
  echo "Building Docker image..."
  docker build -t $PROJECT_NAME .
}
# Run docker container
start_server(){
  echo "Running server using docker compose..."
  # docker run -d -p 8000:8000 $PROJECT_NAME
  docker compose up -d
}

# Main function
main() {
  case "$1" in
    setup)
      setup_environment
      ;;
    lint)
      lint_code
      ;;
    test)
      run_tests
      ;;
    build)
      build_project
      ;;
    start)
      if [ "$CI" = "true" ]; then
        echo "Running in CI - Skipping docker-compose up."
      else
        start_server
      fi
      # start_server
      ;;
    all|"")
      setup_environment
      lint_code
      run_tests
      build_project
      start_server
      ;;
    *)
      echo "Usage: $0 {setup|lint|test|build|start|all}"
      exit 1
      ;;
  esac
}

main "$@"