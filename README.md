# Eudic VS Code Extension

Use the local eudic for tranlate / lookup word

## Features

- Right-click on selected text to see the "Send to Eudic" option.
- Sends the selected text to Eudic application using the command: `$binpath -w $textselected`.
- Configurable binary path for the Eudic application.
- Displays an error message if the binary path does not exist.
- Auto activate the Eudic window in Windows.

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