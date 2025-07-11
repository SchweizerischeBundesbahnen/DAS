import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { SbbFormFieldModule } from "@sbb-esta/angular/form-field";
import { SbbInputModule } from "@sbb-esta/angular/input";
import { MqService } from "../mq.service";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { firstValueFrom, map, Subscription } from "rxjs";
import { CommonModule } from "@angular/common";
import { MqttConnectionState } from "ngx-mqtt";
import { OidcSecurityService } from "angular-auth-oidc-client";
import { SbbCheckboxModule } from "@sbb-esta/angular/checkbox";
import { environment } from "../../environments/environment";
import { MessageTableComponent, TableData } from "./message-table/message-table.component";
import { SbbTableDataSource } from "@sbb-esta/angular/table";
import {
  G2BEventNSPOptions,
  READONLY_MODE,
  SferaXmlCreation,
  SpRequestOptions,
  TcRequestOptions
} from "./sfera-xml-creation";
import { SbbAccordionModule } from "@sbb-esta/angular/accordion";
import { SessionsService } from "../sfera-discover/sessions.service";
import { ActivatedRoute } from "@angular/router";

@Component({
  selector: 'app-sfera-observer',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    SbbFormFieldModule,
    SbbInputModule,
    SbbButtonModule,
    SbbCheckboxModule,
    MessageTableComponent,
    SbbAccordionModule,
  ],
  templateUrl: './sfera-observer.component.html',
  styleUrl: './sfera-observer.component.scss'
})
export class SferaObserverComponent implements OnInit, OnDestroy {
  private oidcSecurityService = inject(OidcSecurityService);
  protected mqService = inject(MqService);
  private sessionsService = inject(SessionsService);
  private route = inject(ActivatedRoute);

  companyControl = new FormControl('1085', {nonNullable: true});
  trainControl = new FormControl('1513', {nonNullable: true});
  dateControl = new FormControl(new Date().toISOString().split('T')[0], {nonNullable: true});
  clientIdControl = new FormControl(environment.mqttServiceOptions.clientId, {nonNullable: true});
  environmentControl = new FormControl(environment.customTopicPrefix.length > 0, {nonNullable: true});
  customPrefixControl = new FormControl(environment.customTopicPrefix, {nonNullable: true});
  xmlStringControl = new FormControl('', {nonNullable: true});
  g2bTopic?: string;
  b2gTopic?: string;
  eventTopic?: string;
  dataSource: SbbTableDataSource<TableData> = new SbbTableDataSource<TableData>([]);
  data: TableData[] = [];

  g2bSubscription?: Subscription;
  b2gSubscription?: Subscription;
  eventSubscription?: Subscription;

  protected readonly MqttConnectionState = MqttConnectionState;

  ngOnInit() {
    const params = this.route.snapshot.paramMap;
    const operationNumber = params.get('operationalNumber');
    if (operationNumber) this.trainControl.setValue(operationNumber);
    const companyCode = params.get('companyCode');
    if (companyCode) this.companyControl.setValue(companyCode);
    const clientId = params.get('clientId');
    if (clientId) this.clientIdControl.setValue(clientId);
    const date = params.get('date');
    if (date) this.dateControl.setValue(date);
    if (params.keys.length > 0) {
      this.observe()
    }
  }

  async observe() {
    const customTopicPrefix = this.environmentControl.value ? this.customPrefixControl.value : '';
    const trainOperation = this.trainControl.value + '_' + this.dateControl.value;
    this.g2bTopic = customTopicPrefix + '90940/2/G2B/' + this.companyControl.value + '/' + trainOperation + '/' + this.clientIdControl.value;
    this.b2gTopic = customTopicPrefix + '90940/2/B2G/' + this.companyControl.value + '/' + trainOperation + '/' + this.clientIdControl.value;
    this.eventTopic = customTopicPrefix + '90940/2/event/' + this.companyControl.value + '/' + trainOperation + '/' + this.clientIdControl.value;
    const token = await firstValueFrom(this.oidcSecurityService.getAccessToken());
    const username = await firstValueFrom(this.oidcSecurityService.getUserData().pipe(map((data) => data?.preferred_username)));
    await this.mqService.connect(username, token);

    this.g2bSubscription = this.mqService.observe(this.g2bTopic)
      .subscribe(value => {
        this.addData(value.payload.toString(), 'g2b');
      })
    this.b2gSubscription = this.mqService.observe(this.b2gTopic)
      .subscribe(value => {
        this.addData(value.payload.toString(), 'b2g');
      })
    this.eventSubscription = this.mqService.observe(this.eventTopic).subscribe(value => {
      this.addData(value.payload.toString(), 'event');
    })
  }

  disconnect() {
    this.data = [];
    this.dataSource = new SbbTableDataSource<TableData>([]);
    this.g2bSubscription?.unsubscribe();
    this.b2gSubscription?.unsubscribe();
    this.eventSubscription?.unsubscribe();
    this.mqService.disconnect();
  }

  ngOnDestroy() {
    this.disconnect();
  }

  addData(xml: string, topic: string) {
    const document = this.toDom(xml);
    const row = {
      direction: topic == "b2g" ? "↑" : "↓",
      topic: topic,
      type: this.getType(document) || '',
      info: this.getInfo(document) || '',
      message: xml
    }

    this.data.push(row);
    this.dataSource = new SbbTableDataSource<TableData>(this.data);
  }

  toDom(xmlString: string) {
    const parser = new DOMParser();
    return parser.parseFromString(xmlString, 'text/xml');
  }

  sendXml() {
    const xmlString = this.xmlStringControl.value;
    this.mqService.publish(this.b2gTopic!, xmlString);
  }

  sendHandshakeRequest() {
    const handshakeRequest = SferaXmlCreation.createHandshakeRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      supportedModes: READONLY_MODE
    });
    this.mqService.publish(this.b2gTopic!, handshakeRequest);
  }

  sendJPRequest() {
    const jpRequest = SferaXmlCreation.createRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      jpRequests: [{
        trainIdentification: {
          company: this.companyControl.value,
          operationalTrainNumber: this.trainControl.value,
          startDate: this.dateControl.value
        }
      }]
    });
    this.mqService.publish(this.b2gTopic!, jpRequest);
  }

  sendSPRequest() {
    const jpReplies = this.data.filter(row => row.type === 'SFERA_G2B_ReplyMessage' && row.info.includes('JP: Valid'))
    if (jpReplies.length === 0) {
      alert('No JP request sent')
      return;
    }

    const dom = this.toDom(jpReplies[jpReplies.length - 1].message)

    const segmentProfileReference = Array.from(dom.getElementsByTagName('SegmentProfileReference'));
    const segmentProfiles = segmentProfileReference.map(element => {
      const spId = element.getAttribute('SP_ID');
      const imId = element.getElementsByTagName('IM_ID')[0].textContent;
      const minorVersion = element.getAttribute('SP_VersionMinor');
      const majorVersion = element.getAttribute('SP_VersionMajor');

      return {
        spZone: {
          imId: imId
        },
        spId: spId,
        majorVersion: majorVersion,
        minorVersion: minorVersion
      } as SpRequestOptions;
    });

    const spRequest = SferaXmlCreation.createRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      spRequests: segmentProfiles
    });
    this.mqService.publish(this.b2gTopic!, spRequest);
  }

  sendTCRequest() {
    const jpReplies = this.data.filter(row => row.type === 'SFERA_G2B_ReplyMessage' && row.info.includes('JP: Valid'))
    if (jpReplies.length === 0) {
      alert('No JP request sent')
      return;
    }

    const dom = this.toDom(jpReplies[jpReplies.length - 1].message)

    const trainCharacteristicsRefs = Array.from(dom.getElementsByTagName('TrainCharacteristicsRef'));

    const trainCharacteristics = trainCharacteristicsRefs.map(element => {
      const tcId = element.getAttribute('TC_ID');
      const ruId = element.getElementsByTagName('TC_RU_ID')[0].textContent;
      const minorVersion = element.getAttribute('TC_VersionMajor');
      const majorVersion = element.getAttribute('TC_VersionMinor');

      return {
        ruId: ruId,
        tcId: tcId,
        majorVersion: majorVersion,
        minorVersion: minorVersion
      } as TcRequestOptions;
    });

    const tcRequest = SferaXmlCreation.createRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      tcRequests: trainCharacteristics
    });
    this.mqService.publish(this.b2gTopic!, tcRequest);
  }

  sendSessionTermination() {
    const sessionTerminationEvent = SferaXmlCreation.createEvent({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      sessionTermination: true
    });
    this.mqService.publish(this.b2gTopic!, sessionTerminationEvent);
  }

  sendHSRWrongSferaVersion() {
    const handshakeRequest = SferaXmlCreation.createHandshakeRequest({
      header: {
        sferaVersion: '3.00',
        sourceDevice: this.clientIdControl.value
      },
      supportedModes: READONLY_MODE
    });
    this.mqService.publish(this.b2gTopic!, handshakeRequest);
  }

  sendHSRWrongConnectivity() {
    const handshakeRequest = SferaXmlCreation.createHandshakeRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      supportedModes: [{
        drivingMode: 'Read-Only', connectivity: 'Standalone', architecture: 'BoardAdviceCalculation'
      }]
    });
    this.mqService.publish(this.b2gTopic!, handshakeRequest);
  }

  sendHSRWrongArchitecture() {
    const handshakeRequest = SferaXmlCreation.createHandshakeRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      supportedModes: [{
        drivingMode: 'Read-Only', connectivity: 'Connected', architecture: 'GroundAdviceCalculation'
      }]
    });
    this.mqService.publish(this.b2gTopic!, handshakeRequest);
  }

  sendHSRDriverWithoutReadonly() {
    const handshakeRequest = SferaXmlCreation.createHandshakeRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      supportedModes: [{
        drivingMode: 'DAS not connected to ATP',
        connectivity: 'Connected',
        architecture: 'BoardAdviceCalculation'
      }]
    });
    this.mqService.publish(this.b2gTopic!, handshakeRequest);
  }

  sendHSRDriverAndReadOnly() {
    const handshakeRequest = SferaXmlCreation.createHandshakeRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      statusReportsEnabled: true,
      supportedModes: [{
        drivingMode: 'DAS not connected to ATP',
        connectivity: 'Connected',
        architecture: 'BoardAdviceCalculation'
      }, {
        drivingMode: 'Read-Only', connectivity: 'Connected', architecture: 'BoardAdviceCalculation'
      }]
    });
    this.mqService.publish(this.b2gTopic!, handshakeRequest);
  }

  sendJPRequestWithWrongTrainnumber() {
    const jpRequest = SferaXmlCreation.createRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      jpRequests: [{
        trainIdentification: {
          company: this.companyControl.value,
          operationalTrainNumber: '' + (parseInt(this.trainControl.value) * 2),
          startDate: this.dateControl.value
        }
      }]
    });
    this.mqService.publish(this.b2gTopic!, jpRequest);
  }

  sendJPRequestWithWrongCompany() {
    const jpRequest = SferaXmlCreation.createRequest({
      header: {
        sourceDevice: this.clientIdControl.value
      },
      jpRequests: [{
        trainIdentification: {
          company: '' + (parseInt(this.companyControl.value) * 2),
          operationalTrainNumber: this.trainControl.value,
          startDate: this.dateControl.value
        }
      }]
    });
    this.mqService.publish(this.b2gTopic!, jpRequest);
  }

  nextLocation() {
    this.sessionsService.nextLocation({
      operationalNumber: this.trainControl.value,
      clientId: this.clientIdControl.value!,
      companyCode: this.companyControl.value,
      date: this.dateControl.value,
    }).subscribe()
  }

  sendG2BEvent(options: G2BEventNSPOptions) {
    const event = SferaXmlCreation.createG2BEventNsp(options);
    this.mqService.publish(this.eventTopic!, event);
  }

  private getType(document: Document) {
    return document.firstChild?.nodeName || '';
  }

  private getInfo(document: Document) {

    const type = this.getType(document);

    if (type == "SFERA_G2B_ReplyMessage") {
      if (this.isHandshakeAcknowledgement(document)) {
        return `HS-ACK: ${this.getSelectedArchitecture(document)}, ${this.getSelectedConnectivity(document)}`;
      } else if (this.isHandshakeReject(document)) {
        return `HS-REJECT: ${this.getRejectReason(document)}`;
      } else if (this.isMessageResponse(document)) {
        const result = this.getMessageResponseResult(document);
        if (result == 'OK') {
          return 'OK';
        } else if (result == 'ERROR') {
          return `ERROR: ${this.getErrorCode(document)}`;
        }
      } else if (this.containsElement(document, 'JourneyProfile')) {
        return `JP: ${this.getJourneyProfileStatus(document)}, #SP: ${this.getJourneyProfileNumberOfSPs(document)}`;
      } else if (this.containsElement(document, 'SegmentProfile')) {
        return this.getSegmentProfiles(document);
      } else if (this.containsElement(document, 'TrainCharacteristics')) {
        return this.getTrainCharacteristics(document);
      } else if (this.containsElement(document, 'RelatedTrainInformation')) {
        return 'RelatedTrainInformation';
      }
    } else if (type == "SFERA_B2G_RequestMessage") {
      if (this.isHandshakeRequest(document)) {
        return `HS-REQUEST`;
      }

      const requestTypes = ['JP_Request', 'SP_Request', 'TC_Request', 'RelatedTrainInformationRequest']
      const requestedTypes: string[] = [];

      for (const requestType of requestTypes) {
        if (this.containsElement(document, requestType)) {
          requestedTypes.push(requestType)
        }
      }

      return requestedTypes.join(", ");
    } else if (type == "SFERA_G2B_EventMessage") {
      if (this.containsElement(document, 'RelatedTrainInformation'))
        return 'RelatedTrainInformation';
      if (this.containsElement(document, 'JourneyProfile')) {
        return `JP Update: ${this.getJourneyProfileStatus(document)}, #SP: ${this.getJourneyProfileNumberOfSPs(document)}`;
      }
    } else if (type == "SFERA_B2G_EventMessage") {
      if (this.containsElement(document, 'SessionTermination'))
        return 'SessionTermination';
    }
    return "unknown";
  }

  private isMessageResponse(document: Document) {
    return document.getElementsByTagName("G2B_MessageResponse")?.length > 0;
  }

  private getMessageResponseResult(document: Document) {
    return document.getElementsByTagName("G2B_MessageResponse").item(0)?.getAttribute("result") || undefined;
  }

  private getErrorCode(document: Document) {
    return document.getElementsByTagName("G2B_Error").item(0)?.getAttribute("errorCode") || undefined;
  }

  private isHandshakeReject(document: Document): boolean {
    return document.getElementsByTagName("HandshakeReject")?.length > 0;
  }

  private isHandshakeAcknowledgement(document: Document): boolean {
    return document.getElementsByTagName("HandshakeAcknowledgement")?.length > 0;
  }

  private isHandshakeRequest(document: Document) {
    return document.getElementsByTagName("HandshakeRequest")?.length > 0;
  }

  private getSelectedArchitecture(document: Document) {
    return document.getElementsByTagName("DAS_OperatingModeSelected").item(0)?.getAttribute("DAS_architecture") || undefined;
  }

  private getSelectedConnectivity(document: Document) {
    return document.getElementsByTagName("DAS_OperatingModeSelected").item(0)?.getAttribute("DAS_connectivity") || undefined;
  }

  private getRejectReason(document: Document) {
    return document.getElementsByTagName("HandshakeReject").item(0)?.getAttribute("handshakeRejectReason") || undefined;
  }

  private containsElement(document: Document, elementName: string) {
    return document.getElementsByTagName(elementName)?.length > 0;
  }

  private getJourneyProfileStatus(document: Document) {
    return document.getElementsByTagName("JourneyProfile").item(0)?.getAttribute("JP_Status") || undefined;
  }

  private getJourneyProfileNumberOfSPs(document: Document) {
    return document.getElementsByTagName("SegmentProfileReference")?.length || undefined;
  }

  private getSegmentProfiles(document: Document) {
    const segmentProfiles = Array.from(document.getElementsByTagName("SegmentProfile"));
    return segmentProfiles.map(segmentProfile => `SP ${this.getSegmentProfileId(segmentProfile)}: ${this.getSegmentProfileStatus(segmentProfile)}, Length: ${this.getSegmentProfileLength(segmentProfile)}`).join(', ')
  }

  private getTrainCharacteristics(document: Document) {
    const trainCharacteristics = Array.from(document.getElementsByTagName("TrainCharacteristics"));
    return trainCharacteristics.map(trainCharacteristic => `TC ${this.getTrainCharacteristicsId(trainCharacteristic)}`).join(', ');
  }

  private getSegmentProfileStatus(element: Element) {
    return element.getAttribute("SP_Status") || undefined;
  }

  private getSegmentProfileLength(element: Element) {
    return element.getAttribute("SP_Length") || undefined;
  }

  private getSegmentProfileId(element: Element) {
    return element.getAttribute("SP_ID");
  }

  private getTrainCharacteristicsId(element: Element) {
    return element.getAttribute("TC_ID");
  }
}
