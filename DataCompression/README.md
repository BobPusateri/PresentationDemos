# The Ins and Outs of SQL Server Data Compression

* [Parking Tickets Demo Database](https://bobpusateri.blob.core.windows.net/shared/DemoData/ParkingTicketsDemoDB.7z)
* [Slide Deck](https://bobpusateri.blob.core.windows.net/shared/DemoData/EightKB_Data_Compression.pdf)

### Resources
* Bradley Ball (posting for [SQL University](http://sqlchicken.com/sql-university/)) [has](http://www.sqlballs.com/2011/10/sql-university-compression-week-lesson.html) [three](http://www.sqlballs.com/2011/10/lesson-2-internal-structures-vardecimal.html) [posts](http://www.sqlballs.com/2011/10/sql-university-lesson-3-page.html) on data compression
* [Jonathan Kehayias' blog post on using extended events to track page compression operations](http://www.sqlskills.com/blogs/jonathan/post/An-XEvent-a-Day-(28-of-31)-e28093-Tracking-Page-Compression-Operations.aspx)
* [Brent Ozar takes a light-hearted look at data compression](http://www.brentozar.com/archive/2009/08/sql-server-data-compression-its-a-party/)
* [Paul Randal Q&A on data and backup compression](http://www.sqlskills.com/BLOGS/PAUL/post/Conference-Questions-Pot-Pourri-9-QA-around-compression-features.aspx)
* [Sanjay Mishra whiteppaer: Data Compression: Strategy, Capacity Planning, and Best Practices](http://msdn.microsoft.com/en-us/library/dd894051(SQL.100).aspx)
* [Microsoft Certified Master Readiness Video: New Database Structures in SQL Server 2008](http://technet.microsoft.com/en-us/sqlserver/gg313758.aspx) (first segment is on data compression)
* [Niko Neugebauer has over 130 blog posts on columnstore indexes](http://www.nikoport.com/columnstore/)



### Abstract
While data compression is best-known for reducing a database's size on disk, it's also an effective tool for making your queries fly. Come see how reduced disk usage and increased performance mean that with compression, less really can be more! This session will arm you with the knowledge and understanding to capitalize on both of these aspects of SQL Server's row and page compression features, as well as columnstore and updateable columnstore indexes. We'll combine a lesson on the internals of compression with real-world scenarios to show you how to determine the most appropriate compression type for any situation. Since there's no such thing as a "free lunch" in computing, the drawbacks of these features will also be discussed.

_These materials are licensed under the [Creative Commons Attribution Non-Commercial ShareAlike license](https://creativecommons.org/licenses/by-nc-sa/4.0/), a localized version of which is available [inside this repository](https://github.com/BobPusateri/PresentationDemos/blob/master/License.md)._