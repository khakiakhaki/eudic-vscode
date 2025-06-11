# Eudic VS Code Extension

This extension adds a right-click context menu option called "Eudic" for selected text in Visual Studio Code. When selected, it sends the highlighted text to the Eudic application using a specified command line format.

## Features

- Right-click on selected text to see the "Eudic" option.
- Sends the selected text to Eudic using the command: `$binpath -w $textselected`.
- Configurable binary path for the Eudic application.
- Displays an error message if the binary path does not exist.

## Installation

1. Clone the repository or download the source code.
2. Open the project in Visual Studio Code.
3. Run the command `npm install` to install any dependencies.
4. Press `F5` to launch the extension in a new Extension Development Host window.

## Usage

1. Select the text you want to send to Eudic.
2. Right-click to open the context menu.
3. Click on the "Eudic" option.
4. The selected text will be sent to Eudic.

## Configuration

To set the binary path for Eudic, add the following to your `settings.json`:

```json
"eudic.binaryPath": "/path/to/eudic"
```

Make sure to replace `/path/to/eudic` with the actual path to the Eudic binary on your system.

## Troubleshooting

- If you encounter an error stating that the binary path does not exist, please verify that the path is correct and that the Eudic application is installed.

## License

This project is licensed under the MIT License. See the LICENSE file for details.