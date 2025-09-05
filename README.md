<script type="text/javascript">
        var gk_isXlsx = false;
        var gk_xlsxFileLookup = {};
        var gk_fileData = {};
        function filledCell(cell) {
          return cell !== '' && cell != null;
        }
        function loadFileData(filename) {
        if (gk_isXlsx && gk_xlsxFileLookup[filename]) {
            try {
                var workbook = XLSX.read(gk_fileData[filename], { type: 'base64' });
                var firstSheetName = workbook.SheetNames[0];
                var worksheet = workbook.Sheets[firstSheetName];

                // Convert sheet to JSON to filter blank rows
                var jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1, blankrows: false, defval: '' });
                // Filter out blank rows (rows where all cells are empty, null, or undefined)
                var filteredData = jsonData.filter(row => row.some(filledCell));

                // Heuristic to find the header row by ignoring rows with fewer filled cells than the next row
                var headerRowIndex = filteredData.findIndex((row, index) =>
                  row.filter(filledCell).length >= filteredData[index + 1]?.filter(filledCell).length
                );
                // Fallback
                if (headerRowIndex === -1 || headerRowIndex > 25) {
                  headerRowIndex = 0;
                }

                // Convert filtered JSON back to CSV
                var csv = XLSX.utils.aoa_to_sheet(filteredData.slice(headerRowIndex)); // Create a new sheet from filtered array of arrays
                csv = XLSX.utils.sheet_to_csv(csv, { header: 1 });
                return csv;
            } catch (e) {
                console.error(e);
                return "";
            }
        }
        return gk_fileData[filename] || "";
        }
        </script><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WorkForge - Productivity Task Manager</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0 auto; max-width: 800px; padding: 20px; }
        h1, h2 { color: #333; }
        h1 { border-bottom: 2px solid #333; padding-bottom: 10px; }
        ul { list-style-type: disc; padding-left: 20px; }
        a { color: #007BFF; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .note { background-color: #f9f9f9; padding: 10px; border-left: 4px solid #007BFF; }
    </style>
</head>
<body>
    <h1>WorkForge - Productivity Task Manager</h1>
    <p>WorkForge is a sleek productivity app designed to simplify task and project management. Built for iOS, it helps users create and organize jobs with deliverables, checklists, notes, and due dates. The app offers customizable task colors, reminder notifications, and options to mark tasks as complete or delete them, all within an intuitive interface featuring tabs for due tasks, checklists, notes, and job details.</p>

    <h2>Features</h2>
    <ul>
        <li><strong>Job Management</strong>: Create and manage jobs with associated tasks.</li>
        <li><strong>Deliverables</strong>: Add tasks with due dates and customizable colors.</li>
        <li><strong>Checklists</strong>: Organize subtasks within jobs.</li>
        <li><strong>Notes</strong>: Attach notes to jobs for additional context.</li>
        <li><strong>Reminders</strong>: Set notifications for due dates.</li>
        <li><strong>Task Actions</strong>: Mark complete, delete, or change colors via swipe gestures.</li>
        <li><strong>User-Friendly Interface</strong>: Navigate easily with dedicated tabs.</li>
    </ul>

    <h2>Installation</h2>
    <ol>
        <li>Clone the repository: <code>git clone https://github.com/yourusername/WorkForge.git</code></li>
        <li>Open the project in Xcode.</li>
        <li>Ensure you have Xcode 18.4 or later installed.</li>
        <li>Build and run on an iPhone simulator (e.g., iPhone 16).</li>
    </ol>

    <h2>Usage</h2>
    <ul>
        <li>Launch the app to access the HomeView.</li>
        <li>Add a job (e.g., "Job 1") and navigate to its "Due" tab.</li>
        <li>Create deliverables, set due dates, and configure reminders or colors.</li>
        <li>Use swipe actions to manage tasks efficiently.</li>
    </ul>

    <h2>Requirements</h2>
    <ul>
        <li>iOS 18.4 or higher</li>
        <li>Xcode 18.4</li>
        <li>Swift 5</li>
    </ul>

    <h2>Contributing</h2>
    <p>Contributions are welcome! Please fork the repository and submit pull requests for review.</p>

    <h2>License</h2>
    <p><a href="LICENSE">MIT License</a> - Feel free to modify and distribute, but include the original license.</p>

    <h2>Contact</h2>
    <p>For questions, reach out at <a href="mailto:your-email@example.com">your-email@example.com</a>.</p>

    <div class="note">
        <p><em>Note: This project is under active development. Expect updates and additional features soon!</em></p>
    </div>
</body>
</html>
