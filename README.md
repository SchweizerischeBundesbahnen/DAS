# Driver Advisory System

## Normative scope

This project covers mainly the **DAS On-Board** (aka **DAS**, **DAS OB**) railway undertaking (RU)
component
according to [UIC IRS 90940:Ed2](https://uic.org/events/uic-irs-90940-edition-2-sfera-protocol),
also
see [high-level system architecture](./docs/content/architecture/05_building_block_view/01_whitebox_view.md).

Out of Scope:

* The Traffic Management System **IM DAS-TS** is not part of this project.
* Operating aspects to national data-sources involved (for e.g. the Swiss IM DAS-TS instance
  TMS-VAD).

## Introduction

Driver Advisory System (DAS) is an innovative tool designed to assist train drivers in the delivery
of efficient and punctual train services. By integrating a wide range of data sources, including
live positioning, infrastructure characteristics, and real-time transport plans, the system
calculatesand presents the ideal driving profile for each journey.

RUs and countries might have its own additional legal requirements and specialities, therefore this
repository is initially dedicated to RUs of Switzerland covering encompassing aspects necessary for
implementation and integration.

SFERA Protocol is used for some international compatibility, but may also contain country
specific extensions (NSPs).

## Structure

This repository is structured into several key modules, each dedicated to a specific aspect of the
system.

### Mobile App

DAS-OB (aka **DAS-Client** within this project)

- [das_client](das_client/README.md)
    - [Dart](https://dart.dev/)
    - [Flutter](https://flutter.dev/)

### Backend (aka **DAS-Backend** within this project)

Important:

* This component is not a **RU DAS-TS** implementation, but offers additional related services.

- [das_backend](das_backend/README.md)
    - [Java](https://www.java.com/de/), [openJDK](https://openjdk.org/)
    - [Spring Framework](https://spring.io/projects/spring-framework)
      with [Spring Boot](https://spring.io/projects/spring-boot)

![business_context.drawio.svg](docs/content/architecture/03_context/business_context.drawio.svg)

### Admintool

- [das_admintool](das_admintool/README.md)
    - [TypeScript](https://www.typescriptlang.org/)
    - [Angular](https://angular.io/)

### Tools

#### SFERA Mock

Mock IM DAS-TS

- [sfera_mock](sfera_mock/README.md)
    - [Java](https://www.java.com/)
    - [Spring Framework](https://spring.io/projects/spring-framework)
      with [Spring Boot](https://spring.io/projects/spring-boot)

#### Playground

- [das_playground](das_playground/README.md)
    - [TypeScript](https://www.typescriptlang.org/)
    - [Angular](https://angular.io/)

## Getting-Started

Please refer to the README files in the respective modules for detailed instructions.

## License

This project is licensed under [GPL v3.0](LICENSE).

## Contributing

This repository includes a [CONTRIBUTING.md](CONTRIBUTING.md) file that outlines how to contribute
to the project, including how to submit bug reports, feature requests, and pull requests.

## Coding Standards

This repository includes a [CODING_STANDARDS.md](CODING_STANDARDS.md) file that outlines the coding
standards that you should follow when contributing to the project.

## Code of Conduct

To ensure that your project is a welcoming and inclusive environment for all contributors, you
should establish a good [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
