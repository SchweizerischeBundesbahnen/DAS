import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'fileSize'
})
export class FileSizePipe implements PipeTransform {

  transform(value: number): unknown {
    if (isNaN(value) || value === 0) return '0 Bytes';

    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(value) / Math.log(1024));
    return `${parseFloat((value / Math.pow(1024, i)).toFixed(2))} ${sizes[i]}`;
  }
}
