# Locks, Blocks, and Snapshots: Maximizing Database Concurrency

* [ZipCodeData Demo Database](https://www.bobpusateri.com/r/IsolationLevels-DB-GitHub)
* [Slide Deck](https://www.bobpusateri.com/r/IsolationLevels-Deck-GitHub)

### Abstract
The ability for multiple processes to query and update a database concurrently has long-been a hallmark of database technology, but this feature can be implemented in many ways. This session will explore the different isolation levels supported by SQL Server and Azure SQL Database, why they exist, how they work, how they differ, and how In-Memory OLTP fits in. Demonstrations will also show how different isolation levels can determine not only the performance, but also the result set returned by a query.

Additionally, attendees will learn how to choose the optimal isolation level for a given workload, and see how easy it can be to improve performance by adjusting isolation settings. An understanding of SQL Server’s isolation levels can help relieve bottlenecks that no amount of query tuning or indexing can address – attend this session and gain Senior DBA-level skills on how to maximize your database’s ability to process transactions concurrently.

_These materials are licensed under the [Creative Commons Attribution Non-Commercial ShareAlike license](https://creativecommons.org/licenses/by-nc-sa/4.0/), a localized version of which is available [inside this repository](https://github.com/BobPusateri/PresentationDemos/blob/master/License.md)._