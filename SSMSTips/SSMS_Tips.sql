/*

	SSMS Tips


	The demo database this code utilizes is the Chicago Parking Ticket Database
	
	https://www.bobpusateri.com/archive/2018/09/new-data-set-chicago-parking-tickets/

	Database download (~500MB): 
	https://www.bobpusateri.com/r/parking-tickets


*/











/*
	0.
	What Version of SSMS are you running?
*/




























































/*
	1.
	Error in your syntax? Double-click on it to go right there!
*/
USE [ParkingTickets]
GO

SELECT
	t.ticket_number,
	t.plate_number,
	t.license_state,
	t.license_type,
	t.car_make,
	t.issue_date,
	t.violation_location,
	t.violation_code,
	v.[Description] AS violation_description,
	v.Cost AS violation_cost,
	t.badge,
	t,unit,
	q.[Description] AS ticket_queue,
	d.[Description] AS hearing_disposition
FROM [dbo].[Ticket] t
LEFT JOIN [dbo].[Violation] v ON t.violation_code = v.Code
LEFT JOIN [dbo].[TicketQueue] q ON t.ticket_queue_id = q.ID
LEFT JOIN [dbo].[HearingDisposition] d ON t.hearing_dispo_id = d.ID;


















/*
	2.
	Query Shortcuts

	Tools > Options > Keyboard > Query Shortcuts

	Assign a stored procedure to the following keys:
	- Alt + F1
	- Ctrl + F1
	- Ctrl + #
*/

-- example: Alt + F1 = sp_help

-- can also highlight an object name and run; will be passed as a parameter
dbo.Ticket














/*
	3.
	Snippets

	Right-click in the query window and select "Insert Snippet"
	Keyboard shortcut: Ctrl+K, Ctrl+X

	To manage snippets or add your own, use Code Snippets Manager
	Tools > Code Snippets Manager
*/









-- Snippets are written as XML files
-- Example: Index > Create Primary XML Index
<?xml version="1.0" encoding="utf-8" ?>
<CodeSnippets  xmlns="http://schemas.microsoft.com/VisualStudio/2005/CodeSnippet">
<_locDefinition xmlns="urn:locstudio">
    <_locDefault _loc="locNone" />
    <_locTag _loc="locData">Title</_locTag>
    <_locTag _loc="locData">Description</_locTag>
    <_locTag _loc="locData">Author</_locTag>
    <_locTag _loc="locData">ToolTip</_locTag>
</_locDefinition>
	<CodeSnippet Format="1.0.0">
		<Header>
			<Title>Create Primary XML Index</Title>
                        <Shortcut></Shortcut>
			<Description>Creates a primary XML index.</Description>
			<Author>Microsoft Corporation</Author>
			<SnippetTypes>
				<SnippetType>Expansion</SnippetType>
			</SnippetTypes>
		</Header>
		<Snippet>
			<Declarations>
                                <Literal>
                                	<ID>SchemaName</ID>
                                	<ToolTip>Name of the schema</ToolTip>
                                	<Default>dbo</Default>
                                </Literal>
                                <Literal>
                                	<ID>TableName</ID>
                                	<ToolTip>Name of the table on which the index is applied</ToolTip>
                                	<Default>TableName</Default>
                                </Literal>
                                <Literal>
                                	<ID>XMLIndexName</ID>
                                	<ToolTip>Name of the XML index</ToolTip>
                                	<Default>XMLIndexName</Default>
                                </Literal>
                                <Literal>
                                	<ID>XMLColumn1</ID>
                                	<ToolTip>Name of the XML column on which the index is applied</ToolTip>
                                	<Default>XMLColumn1</Default>
                                </Literal>
			</Declarations>
			<Code Language="SQL"><![CDATA[
CREATE PRIMARY XML INDEX $XMLIndexName$
    ON [$SchemaName$].[$TableName$]
    ($XMLColumn1$)
]]>
			</Code>
		</Snippet>
	</CodeSnippet>
</CodeSnippets>





















/*
	4.
	Line Numbering

	(I already have this enabled)
	Tools > Options > Text Editor > All Languages > General
*/






















/*
	5.
	Drag & Drop Object Explorer Names
*/







/*
	5.5
	Change Drag & Drop text


	Tools > Options > SQL Server Object Explorer > Commands

*/
























/*
	6.
	Execute Shortcut: Ctrl+E
*/


SELECT * FROM sys.Tables;



















/*
	7.
	Vertical Splitter Bar
*/
CREATE PROCEDURE dbo.Really_Long_Proc
    @Name NVARCHAR(200),
    @Address NVARCHAR(200)
AS
/*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*/
    SELECT @Name,@Address 
RETURN 0 












/*
	8.
	Tab Groups


	Right-Click on Tab
		New Horizontal Tab Group
		New Vertical Tab Group

	To Revert: 
	Right-Click on Tab
		Move to Next/Previous Tab Group
*/


















/*
	9.
	Pinned Tabs

	(Click the pin icon in a tab)
	or right-click on tab and select "pin tab"

	Can configure pinned tabs to have a separate row
	Tools > Options > Environment > Tabs and Windows

*/


























/*
	10.
	Tab Names and Status Bar Content

	Tools > Options > Text Editor > Editor Tab and Status Bar
*/


















/*
	11.
	Reset the window layout

	Window > Reset Window Layout


*/



















/*
	12.
	Presenter Mode!

	Available in SSMS 17 and later
	Quick Launch Toolbar
	- PresentOn
	- RestoreDefaultFonts
	- PresentEdit (requires restart)

*/



















/*
	13.
	Colored Connections



	Connect to Server Dialog
	Options > Connection Properties > Custom Color


*/
























/*
	14.
	Save your SSMS Settings

	Tools > Import and Export Settings

*/

























/*
	15.
	Object Explorer Filtering

*/





















/*
	16.
	SSMS Built-In Reports

*/



























/*
	17.
	SSMS Full Screen Mode

	View > Full Screen
	(shortcut: Shift+Alt+Enter)

	To turn it off, repeat
*/




















/*
	17.
	Switching between open tabs

	Ctrl+Tab (switch between tabs - popup window)
	Ctrl+F6 (switch between tabs - no window)

*/




















/*
	18.
	Where is my current file?

	Right-click on tab:
		Copy Full Path
		Open Containing Folder

*/



















/*
	19.
	Changing Case

	TO UPPERCASE: Ctrl+Shift+U
	to lowercase: Ctrl+Shift+L

*/

select *
from dbo.Violation;






















/*
	20.
	SSMS Clipboard Ring

	Cycles through the last 20 values in the clipboard

	Edit > Cycle Clipboard Ring
	Ctrl+Shift+V

*/



























/*
	21.
	Advanced Editing
	(For all your advanced editing needs!)

	Edit > Advanced


*/





















/*
	22.
	Block Editing (aka Column editing)

	Alt+Click (mouse)
	Alt+Shift (keyboard)
*/

SELECT TOP (100)
	plate_number,
	license_state,
	license_type
FROM dbo.Ticket;

















/*
	23.
	Vertical Scroll Bar Map Mode

	Right-click vertical scroll bar > Scroll Bar Options

*/
























/*
	24.
	Registered Servers

	View > Registered Servers
	Ctrl+Alt+G

	Can do custom connection colors at this level as well
*/




















/*
	25.
	Template Browser/Explorer

	View > Template Explorer
	Ctrl+Alt+T

*/






















/*
	26.
	SSMS Web Browser!!

	Ctrl+Click to follow links

	https://www.bobpusateri.com


*/























/*
	27.
	Compare Query Plans

*/


-- capture the plan of the first query and save it

SELECT ticket_number
FROM dbo.vw_ParkingTickets
WHERE violation_code = '0976140B'
-- "EXCESS FUMES/SMOKE DURING OPERATION"


-- capture the second plan

SELECT *
FROM dbo.vw_ParkingTickets
WHERE violation_code = '0976140B'

-- right-click and choose "Compare Showplan"
-- select the saved plan to compare it to




















/*
	28.
	Remove servers from the connection dialog

	hover over them and hit the DELETE key

*/



















/*
	29.
	SSMS Startup Settings

	Tools > Options > Environment > Startup

*/



























/*
	30.
	Toggle the Results Pane

	Window > Show Results Pane
	Ctrl+R

*/




























/*
	31.
	The Scripting Task

	Right-Click on Database > Tasks > Generate Scripts

*/