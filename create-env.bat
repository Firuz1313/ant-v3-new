@echo off
echo Creating .env file...
(
echo # Server Configuration
echo VITE_PORT=3006
echo VITE_VERSION=2.5.8
echo VITE_BASE_URL=/
echo.
echo # API Configuration
echo VITE_API_URL=/api/mock
echo # VITE_API_PROXY_URL=https://your-api-url.com
echo.
echo # Builder.io Configuration
echo # Get your API key from https://www.builder.io
echo # Replace with your actual API key
echo VITE_BUILDER_API_KEY=
echo # Preview URL for Builder.io editor
echo VITE_BUILDER_PREVIEW_URL=http://localhost:3006
echo.
echo # Optional: Development Mode
echo NODE_ENV=development
) > .env
echo .env file created successfully!
echo Please edit .env and add your VITE_BUILDER_API_KEY

