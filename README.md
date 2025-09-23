# 🚀 Windows Dev Tools

<div align="center">

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![C++](https://img.shields.io/badge/C++-00599C?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![C#](https://img.shields.io/badge/C%23-239120?style=for-the-badge&logo=c-sharp&logoColor=white)

**⚡ One-click development environment setup for Windows developers**

</div>

---

## 🎯 Overview

Windows Dev Tools is a curated collection of batch scripts designed to streamline the setup of modern development environments on Windows. Whether you're setting up a new machine or maintaining existing toolchains, these scripts provide automated, error-checked installations of essential development tools.

### ✨ Key Features

- 🔧 **Multi-Language Support** - Python, Node.js, C++, C#
- 🛡️ **Smart Error Handling** - Comprehensive validation and fallback mechanisms
- 📦 **Package Management** - Automated dependency resolution and updates
- 🧹 **Environment Cleanup** - Tools for maintaining clean development environments
- ⚡ **Zero Configuration** - Works out of the box with sensible defaults

---

## 🛠️ Available Scripts

### 🐍 Python Development

| Script | Description | Requirements |
|--------|-------------|--------------|
| `install_python_dev.cmd` | Core Python development tools | Python 3.x, pip |
| `install_python_dev_extended.cmd` | Extended Python toolchain with specialized testing frameworks | Python 3.x, pip |
| `update_pip_packages.cmd` | Updates all outdated Python packages | Python 3.x, pip |
| `restore_pip_default.cmd` | Resets Python environment to clean state | Python 3.x, pip |

**Core Tools Installed:**
- 📋 **Linting & Formatting**: `pylint`, `mypy`, `black`, `isort`, `autopep8`
- 🧪 **Testing Framework**: `pytest` + essential plugins (`pytest-asyncio`, `pytest-timeout`, `pytest-mock`, `pytest-cov`, `pytest-xdist`)
- 📦 **Package Management**: `pip`, `setuptools`, `wheel`, `virtualenv`
- ⚙️ **Environment**: `python-dotenv`

**Extended Tools Include:**
- 📊 **Advanced Testing**: HTML/JSON reporting, benchmarking, re-run failures
- 🌐 **Framework Testing**: Django, Flask, Qt applications
- 🗄️ **Database Testing**: PostgreSQL, MySQL, MongoDB fixtures
- 🔗 **HTTP Testing**: HTTPX, responses mocking, VCR recording
- 📁 **Specialized Testing**: Data directory management, subprocess mocking, socket control

### 🟢 Node.js Development

| Script | Description | Requirements |
|--------|-------------|--------------|
| `install_node_dev.cmd` | Essential Node.js development tools | Node.js, npm, Admin privileges |

**Tools Installed:**
- 📋 **Code Quality**: `eslint`, `prettier`
- 🧪 **Testing**: `jest`
- 🌐 **Development Server**: `live-server`
- 📦 **Package Manager**: Latest `npm`

### ⚙️ C++ Development

| Script | Description | Requirements |
|--------|-------------|--------------|
| `install_c_dev.cmd` | Complete C++ development environment | Visual Studio, vcpkg, winget |

**Tools Installed:**
- 🔧 **Compiler Toolchain**: LLVM, Clang Static Analyzer
- 📊 **Code Coverage**: OpenCppCoverage
- 🧪 **Testing**: Google Test, GMock, Catch2, Benchmark
- 📦 **Libraries**: fmt, spdlog, nlohmann-json, cpprestsdk
- 🏗️ **Build Tools**: CMake, vcpkg integration

### 🔷 C# Development

| Script | Description | Requirements |
|--------|-------------|--------------|
| `install_c#_dev.cmd` | Comprehensive .NET development setup | .NET SDK, winget |

**Tools Installed:**
- 🏗️ **.NET Ecosystem**: .NET 9 SDK, NuGet CLI
- 🗄️ **Database Tools**: SQL Server Management Studio 21, LocalDB
- 📊 **Code Analysis**: SonarScanner for .NET, ReportGenerator
- 🗃️ **ORM Tools**: Entity Framework CLI tools
- 📋 **Project Templates**: Web SPA templates, modern project scaffolding

---

### 🔒 Privilege Requirements

| Script Type | Privileges | Reason |
|-------------|------------|---------|
| Python Scripts | **User** | Package installation to user directory |
| Node.js Script | **Administrator** | Global npm package installation |
| C++ Script | **User** | vcpkg operates in user space |
| C# Script | **User** | dotnet tools install globally to user profile |

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

- 🐛 **Report Issues** - Found a bug? Let us know!
- 💡 **Suggest Features** - Ideas for new tools or improvements
- 🔧 **Submit PRs** - Code contributions are appreciated
- 📖 **Improve Docs** - Help make instructions clearer
- 🧪 **Test Scripts** - Help verify compatibility across Windows versions

---

## 📄 License

This project is licensed under the CRL License - see the [LICENSE.md](./LICENSE.md) file for details.

---

<div align="center">

**⭐ Found this useful? Give it a star!**

Made with 🔥 by [tboy1337](https://github.com/tboy1337)

</div>
