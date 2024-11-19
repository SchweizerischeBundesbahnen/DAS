---
title: Open Source
status: DECIDED
result: DAS is developed OpenSource with a strong Copyleft licence
owner: Dominik Schmucki
date: 2023-03-03
issue: 
tags:
  - adr
---

{{< adr-table "adr" >}}

## Problem Background
### What does open source mean for SBB?
The digital zone wants to strategically utilise the advantages of open source. For us, open source means that we can develop software simply, jointly and across company boundaries.

SBB expects the following effects from this:
* Promote interoperability
* Promote innovation
* Avoid vendor lock-in
* Increase employer attractiveness 

For the development of the digital timetable, it should be considered what the implementation as open source means for the publication as an own solution (Create). The (internal) Open Source Guide contains a list of questions that need to be answered.

## Influences on the Decision
### Effects on DAS
* In addition to operation, there is also the maintenance of the community. Input from the community should be taken into account and processed.
### Effects on the development process
* Checking the licences of the libraries used
* Publication on GitHub
* Discipline in the development process, onboarding / briefing of developers necessary
* Obligation to comply with code quality standards
* Functioning review processes
* CLEW team support limited, CI/CD not on internal environment
* Influence of CENELEC?

### Is the solution suitable for publication?
✅❌️⚠️🛑

| Question                                                                                                                                                                                                                                                                                                                                | Assessement                                                                                                                                                                                                                                                                                                                                                                            | Go |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----|
| **Legal basis:** Do the rights tyo the code belong to SBB? If not, is redistribution of the code permitted?                                                                                                                                                                                                                             | Code is developed first, the rights belong to SBB accordingly (in-house development) or relationships can be clarified contractually.                                                                                                                                                                                                                                                  | ✅  |
| **Potential:**<br/> - Are there use cases for the solution outside SBB? <br/> - Could SBB benefit from an exchange with experts from the open source community? <br/> - Could the solution be improved by external contributions? <br/> - Would members of the project community be potentially interesting candidates for jobs at SBB? | Use cases: <br/> - The timetable can potentially be used on the entire Swiss rail network by various RUs. <br/> - Exchange with experts: Unclear, as technicality is very specific.<br/> - External contributions: When the FO is used by other RUs, there is potential for improvements and bug fixes to be introduced directly as contributions.<br/> - Candidates: Yes, definitely. | ✅|


## Assumptions


## Considered Alternatives
Closed source.

## Decisions
