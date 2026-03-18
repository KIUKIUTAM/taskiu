export GIT_COMMIT=$(git rev-parse --short HEAD)
export BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S)
export BUILD_NUMBER=${1:-"1.0.0"}   # 第一個參數，預設 1.0.0

echo "🚀 Deploying..."
echo "   GIT_COMMIT  = $GIT_COMMIT"
echo "   BUILD_DATE  = $BUILD_DATE"
echo "   BUILD_NUMBER= $BUILD_NUMBER"

docker compose build --no-cache
docker compose up -d