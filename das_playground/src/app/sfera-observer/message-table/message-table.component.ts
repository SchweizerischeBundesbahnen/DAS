import { Component, Input } from '@angular/core';
import { SbbTableDataSource, SbbTableModule } from '@sbb-esta/angular/table';
import { SimpleXmlComponent } from "../../simple-xml/simple-xml.component";
import { FileSizePipe } from "../../pipes/file-size.pipe";
import { DatePipe } from "@angular/common";

export interface TableData {
  direction: string,
  topic: string,
  type: string,
  info: string,
  message: string
}

@Component({
  selector: 'app-message-table',
  imports: [SbbTableModule, SimpleXmlComponent, FileSizePipe, DatePipe],
  templateUrl: './message-table.component.html',
  styleUrl: './message-table.component.scss'
})
export class MessageTableComponent {

  @Input() dataSource: SbbTableDataSource<TableData> = new SbbTableDataSource<TableData>([]);

  displayedColumns: string[] = [
    'timestamp',
    'direction',
    'topic',
    'type',
    'info',
    'message',
    'size'
  ];

}
