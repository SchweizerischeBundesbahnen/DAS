export interface SferaHeaderOptions {
  sferaVersion?: string,
  messageId?: string,
  timestamp?: string,
  sourceDevice?: string,
  sender?: string,
  recipient?: string,
}

export interface HandshakeRequestOptions {
  header?: SferaHeaderOptions,
  statusReportsEnabled?: boolean,
  relatedTrainRequest?: 'None' | 'OwnTrain' | 'RelatedTrains' | 'OwnTrainAndRelatedTrains' | 'OwnTrainAndOrRelatedTrains',
  supportedModes?: SupportedOperationModes[]
}

export interface TrainIdentification {
  startDate: string;
  operationalTrainNumber: string;
  company: string
}

export interface SPZone {
  imId?: string;
  nidC?: string;
}

export interface SegmentProfileIdentification {
  spZone: SPZone;
  spId: string;
}

export interface JpRequestOptions {
  trainIdentification: TrainIdentification;
  requestFromSegmentProfile?: SegmentProfileIdentification
  jpInUse?: string
}

export interface SpRequestOptions {
  spZone: SPZone;
  spId: string;
  majorVersion: string;
  minorVersion: string;
}

export interface TcRequestOptions {
  ruId: string;
  tcId: string;
  majorVersion: string;
  minorVersion: string;
}

export interface RequestOptions {
  header?: SferaHeaderOptions,
  jpRequests?: JpRequestOptions[],
  spRequests?: SpRequestOptions[],
  tcRequests?: TcRequestOptions[]
}

export interface EventOptions {
  header?: SferaHeaderOptions,
  sessionTermination?: boolean,
}

export interface SupportedOperationModes {
  drivingMode: 'Read-Only' | 'Inactive' | 'DAS not connected to ATP',
  architecture: 'BoardAdviceCalculation' | 'GroundAdviceCalculation',
  connectivity: 'Standalone' | 'Connected',
}

export const INACTIVE_MODE: SupportedOperationModes[] = [{
  drivingMode: 'Inactive', connectivity: 'Standalone', architecture: 'BoardAdviceCalculation'
}];

export const READONLY_MODE: SupportedOperationModes[] = [{
  drivingMode: 'Read-Only', connectivity: 'Connected', architecture: 'BoardAdviceCalculation'
}];

export const ACTIVE_MODE: SupportedOperationModes[] = [{
  drivingMode: 'DAS not connected to ATP',
  connectivity: 'Connected',
  architecture: 'BoardAdviceCalculation'
}, {
  drivingMode: 'Read-Only', connectivity: 'Connected', architecture: 'BoardAdviceCalculation'
}];

export interface G2BEventNSPOptions {
  warn?: boolean,
  koa?: 'wait' | 'waitCancelled' | 'waitHide',
  connectivity?: 'connected' | 'disconnected' | 'wifi'
}

export class SferaXmlCreation {

  static createHandshakeRequest(options?: HandshakeRequestOptions) {
    let headerOptions = options?.header || this.defaultHeader();
    headerOptions = this.fillUndefindeHeaderFields(headerOptions);

    const relatedTrainRequestTag = options?.relatedTrainRequest
      ? `relatedTrainRequest="${options!.relatedTrainRequest}"`
      : '';

    const statusReportsEnabledTag = options?.statusReportsEnabled
      ? `statusReportsEnabled="${options!.statusReportsEnabled}"`
      : '';

    const supportedOperationModes = options?.supportedModes?.map(mode => {
      return `<DAS_OperatingModesSupported DAS_drivingMode="${mode.drivingMode}" DAS_architecture="${mode.architecture}" DAS_connectivity="${mode.connectivity}"/>`;
    })?.join("");

    return `<?xml version="1.0"?>
                  <SFERA_B2G_RequestMessage>
                    <MessageHeader SFERA_version="${headerOptions.sferaVersion}" message_ID="${headerOptions.messageId}" timestamp="${headerOptions.timestamp}" sourceDevice="${headerOptions.sourceDevice}">
                        <Sender>${headerOptions.sender}</Sender>
                        <Recipient>${headerOptions.recipient}</Recipient>
                    </MessageHeader>
                    <HandshakeRequest ${relatedTrainRequestTag} ${statusReportsEnabledTag}>
                        ${supportedOperationModes}
                    </HandshakeRequest>
                </SFERA_B2G_RequestMessage>
    `;
  }

  static createRequest(options: RequestOptions): string {
    let headerOptions = options?.header || this.defaultHeader();
    headerOptions = this.fillUndefindeHeaderFields(headerOptions);

    const jpRequests = this.createJpRequest(options.jpRequests);
    const spRequests = this.createSpRequest(options.spRequests);
    const tcRequests = this.createTcRequest(options.tcRequests);

    return `<?xml version="1.0"?>
                  <SFERA_B2G_RequestMessage>
                    <MessageHeader SFERA_version="${headerOptions.sferaVersion}" message_ID="${headerOptions.messageId}" timestamp="${headerOptions.timestamp}" sourceDevice="${headerOptions.sourceDevice}">
                        <Sender>${headerOptions.sender}</Sender>
                        <Recipient>${headerOptions.recipient}</Recipient>
                    </MessageHeader>
                    <B2G_Request>
                        ${jpRequests}
                        ${spRequests}
                        ${tcRequests}
                    </B2G_Request>
                </SFERA_B2G_RequestMessage>
    `;
  }

  static createEvent(options: EventOptions): string {
    let headerOptions = options?.header || this.defaultHeader();
    headerOptions = this.fillUndefindeHeaderFields(headerOptions);

    const sesssionTermination = this.createSessionTerminationRequest(options?.sessionTermination);

    return `<?xml version="1.0"?>
                <SFERA_B2G_EventMessage>
                  <MessageHeader SFERA_version="${headerOptions.sferaVersion}" message_ID="${headerOptions.messageId}" timestamp="${headerOptions.timestamp}" sourceDevice="${headerOptions.sourceDevice}">
                        <Sender>${headerOptions.sender}</Sender>
                        <Recipient>${headerOptions.recipient}</Recipient>
                  </MessageHeader>
                  <B2G_EventPayload>
                        ${sesssionTermination}
                  </B2G_EventPayload>

              </SFERA_B2G_EventMessage>
    `;
  }

  static createJpRequest(jpRequests: JpRequestOptions[] | undefined): string {
    const strings = jpRequests?.map(jpRequest => {
      const jpInUseElement = jpRequest?.jpInUse
        ? `<JP_InUse JP_Version="${jpRequest.jpInUse}"/>`
        : '';

      const requestFromSegmentProfileElement = jpRequest?.requestFromSegmentProfile
        ? `<RequestFromSegmentProfile SP_ID="${jpRequest.requestFromSegmentProfile.spId}">
                            <SP_Zone>
                                <IM_ID>${jpRequest.requestFromSegmentProfile.spZone.imId}</IM_ID>
                                <NID_C>${jpRequest.requestFromSegmentProfile.spZone.nidC}</NID_C>
                            </SP_Zone>
                        </RequestFromSegmentProfile>`
        : '';

      return `<JP_Request>
                            <TrainIdentification>
                                <OTN_ID>
                                    <teltsi_Company>${jpRequest.trainIdentification.company}</teltsi_Company>
                                    <teltsi_OperationalTrainNumber>${jpRequest.trainIdentification.operationalTrainNumber}</teltsi_OperationalTrainNumber>
                                    <teltsi_StartDate>${jpRequest.trainIdentification.startDate}</teltsi_StartDate>
                                </OTN_ID>
                            </TrainIdentification>
                            ${requestFromSegmentProfileElement}
                            ${jpInUseElement}
                        </JP_Request>
      `;

    });
    return (strings || []).join('');
  }

  static createSpRequest(spRequests: SpRequestOptions[] | undefined): string {
    const strings = spRequests?.map(spRequest => {
      return `<SP_Request SP_VersionMajor="${spRequest.majorVersion}"
                          SP_VersionMinor="${spRequest.minorVersion}"
                          SP_ID="${spRequest.spId}">
                          <SP_Zone>
                              <IM_ID>${spRequest.spZone.imId}</IM_ID>
                          </SP_Zone>
                        </SP_Request>
      `;
    });
    return (strings || []).join('');
  }

  static createTcRequest(tcRequests: TcRequestOptions[] | undefined): string {
    const strings = tcRequests?.map(tcRequest => {
      return `<TC_Request TC_ID="${tcRequest.tcId}">
                <TC_RU_ID>${tcRequest.ruId}</TC_RU_ID>
      </TC_Request>
      `;
    })
    return (strings || []).join('');
  }

  static createSessionTerminationRequest(sessionTermination: boolean | undefined): string {
    return sessionTermination ? `<SessionTermination/>` : '';
  }

  static currentTimestampSferaFormat(date?: Date): string {
    const millisecondsRemoveRegex = /\.[0-9]*/i;
    return (date || new Date()).toISOString().replace(millisecondsRemoveRegex, '');
  }

  static createG2BEventNsp(options: G2BEventNSPOptions): string {
    const header = this.defaultG2BHeader();

    const warnNsp = options.warn ? this.createNsp('warn') : '';
    const koaNsp = options.koa ? this.createNsp('koa', options.koa) : '';
    const connectivityNsp = options.connectivity ? this.createNsp('connectivity', options.connectivity) : '';


    return `<?xml version="1.0"?>
                <SFERA_G2B_EventMessage>
                  <MessageHeader SFERA_version="${header.sferaVersion}" message_ID="${header.messageId}" timestamp="${header.timestamp}" sourceDevice="${header.sourceDevice}">
                        <Sender>${header.sender}</Sender>
                        <Recipient>${header.recipient}</Recipient>
                  </MessageHeader>
                  <G2B_EventPayload>
                    <NetworkSpecificEvent>
                      <teltsi_Company>1085</teltsi_Company>
                      <NSP_GroupName>uxTesting</NSP_GroupName>
                      ${warnNsp}
                      ${koaNsp}
                      ${connectivityNsp}
                    </NetworkSpecificEvent>
                  </G2B_EventPayload>

              </SFERA_G2B_EventMessage>
    `;
  }

  private static createNsp(name: string, value?: string) {
    return `<NetworkSpecificParameter name="${name}" value="${value ?? ''}"/>`
  }

  private static defaultHeader(): SferaHeaderOptions {
    return {
      sferaVersion: '3.00',
      messageId: crypto.randomUUID(),
      timestamp: this.currentTimestampSferaFormat(),
      sourceDevice: 'DAS',
      sender: '1085',
      recipient: '0085',
    }
  }

  private static defaultG2BHeader(): SferaHeaderOptions {
    return {
      sferaVersion: '3.00',
      messageId: crypto.randomUUID(),
      timestamp: this.currentTimestampSferaFormat(),
      sourceDevice: 'TMS',
      sender: '0085',
      recipient: '1085',
    }
  }

  private static fillUndefindeHeaderFields(headerOptions: SferaHeaderOptions) {
    headerOptions.sferaVersion = headerOptions.sferaVersion || '3.00';
    headerOptions.timestamp = headerOptions.timestamp || this.currentTimestampSferaFormat()
    headerOptions.sender = headerOptions.sender || '1085';
    headerOptions.recipient = headerOptions.recipient || '0085';
    headerOptions.messageId = headerOptions.messageId || crypto.randomUUID();
    headerOptions.sourceDevice = headerOptions.sourceDevice || 'DAS';
    return headerOptions;
  }
}

