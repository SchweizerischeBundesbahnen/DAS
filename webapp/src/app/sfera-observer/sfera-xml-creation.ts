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

export interface RequestOptions {
  header?: SferaHeaderOptions,
  jpRequests?: JpRequestOptions[]
  spRequests?: SpRequestOptions[]
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
  drivingMode: 'DAS not connected to ATP', connectivity: 'Connected', architecture: 'BoardAdviceCalculation'
}, {
  drivingMode: 'Read-Only', connectivity: 'Connected', architecture: 'BoardAdviceCalculation'
}];

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

    return `<?xml version="1.0"?>
                  <SFERA_B2G_RequestMessage>
                    <MessageHeader SFERA_version="${headerOptions.sferaVersion}" message_ID="${headerOptions.messageId}" timestamp="${headerOptions.timestamp}" sourceDevice="${headerOptions.sourceDevice}">
                        <Sender>${headerOptions.sender}</Sender>
                        <Recipient>${headerOptions.recipient}</Recipient>
                    </MessageHeader>
                    <B2G_Request>
                        ${jpRequests}
                        ${spRequests}
                    </B2G_Request>
                </SFERA_B2G_RequestMessage>
    `;
  }

  static createEvent(options: EventOptions): string {
    let headerOptions = options?.header || this.defaultHeader();
    headerOptions = this.fillUndefindeHeaderFields(headerOptions);

    const sesssionTermination =  this.createSessionTerminationRequest(options?.sessionTermination);

    return `<?xml version="1.0"?>
                <SFERA_B2G_EventMessage>
                  <MessageHeader SFERA_version="${headerOptions.sferaVersion}" message_ID="${headerOptions.messageId}" timestamp="${headerOptions.timestamp}" sourceDevice="${headerOptions.sourceDevice}">
                        <Sender>${headerOptions.sender}</Sender>
                        <Recipient>${headerOptions.recipient}</Recipient>
                  </MessageHeader>
                  ${sesssionTermination}
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
                                    <Company>${jpRequest.trainIdentification.company}</Company>
                                    <OperationalTrainNumber>${jpRequest.trainIdentification.operationalTrainNumber}</OperationalTrainNumber>
                                    <StartDate>${jpRequest.trainIdentification.startDate}</StartDate>
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

  static createSessionTerminationRequest(sessionTermination: boolean | undefined): string {
    return sessionTermination ? `<SessionTermination/>` : '';
  }

  private static defaultHeader(): SferaHeaderOptions {
    return {
      sferaVersion: '2.01',
      messageId: crypto.randomUUID(),
      timestamp: this.currentTimestampSferaFormat(),
      sourceDevice: 'DAS',
      sender: '1085',
      recipient: '0085',
    }
  }

  static currentTimestampSferaFormat(date?: Date): string {
    const millisecondsRemoveRegex = /\.[0-9]*/i;
    return (date || new Date()).toISOString().replace(millisecondsRemoveRegex, '');
  }

  private static fillUndefindeHeaderFields(headerOptions: SferaHeaderOptions) {
    headerOptions.sferaVersion = headerOptions.sferaVersion || '2.01';
    headerOptions.timestamp = headerOptions.timestamp || this.currentTimestampSferaFormat()
    headerOptions.sender = headerOptions.sender || '1085';
    headerOptions.recipient = headerOptions.recipient || '0085';
    headerOptions.messageId = headerOptions.messageId || crypto.randomUUID();
    headerOptions.sourceDevice = headerOptions.sourceDevice || 'DAS';
    return headerOptions;
  }

}

