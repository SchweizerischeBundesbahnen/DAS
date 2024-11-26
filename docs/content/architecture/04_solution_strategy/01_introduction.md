---
title: 4.1 Introduction
draft: true
cascade:
  type: docs
---
The following list contrasts the [quality goals](../../01_introduction/02_quality_goals/) of DAS with matching architecture approaches and thus provides easy access to the solution.

**Railway operations depend on it (Reliability)**
* decoupling
* caching the data
* reduce number of involved systems

**Provided information is correct (Functional Suitability)**
* comprehensive testing
* read-only View-Model / immutable objects 
* using Mappers

**Reliable and efficient operation (Operability)**
* logging and monitoring
* crash recorder on mobile
* no unnecessary dependencies

**Changes need to be implemented efficiently and safely (Maintainability)**
* no unnecessary dependencies, quality check
* cohesive and well-structured internal data model
* APIM -> 
* modularization
* Interfaces for core abstractions -> 
* using standards
* lint enforced
* check architecture with tools (ArchUnit)

**Support, not distract the engine driver (Usability)**
* intense collaboration between UX- and dev-team

Further goals which are important for DAS:

**Auditability**
* logging
* open source
* comprehensive documentation

**Safety**
* follow (SBB internal) processes to assess risks
* comprehensive testing 