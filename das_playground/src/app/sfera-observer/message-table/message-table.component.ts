import { Component, Input } from '@angular/core';
import { SbbTableDataSource, SbbTableModule } from '@sbb-esta/angular/table';
import { SimpleXmlComponent } from "../../simple-xml/simple-xml.component";

export interface TableData {
  direction: string,
  topic: string,
  type: string,
  info: string,
  message: string
}

@Component({
  selector: 'app-message-table',
  imports: [SbbTableModule, SimpleXmlComponent],
  templateUrl: './message-table.component.html',
  styleUrl: './message-table.component.scss'
})
export class MessageTableComponent {

  @Input() dataSource: SbbTableDataSource<TableData> = new SbbTableDataSource<TableData>([]);

  displayedColumns: string[] = [
    'direction',
    'topic',
    'type',
    'info',
    'message',
  ];

}
