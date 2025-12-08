import {Component} from '@angular/core';
import {
  SbbIconSidebar,
  SbbIconSidebarButton,
  SbbIconSidebarContainer,
  SbbIconSidebarContent,
  SbbIconSidebarLink,
  SbbSidebar,
  SbbSidebarCloseButton,
  SbbSidebarContainer,
  SbbSidebarContent,
  SbbSidebarTitle
} from '@sbb-esta/lyne-angular/sidebar';
import {SbbBlockLink} from '@sbb-esta/lyne-angular/link/block-link';
import {SbbLinkList} from '@sbb-esta/lyne-angular/link-list/link-list';
import {SbbTooltipDirective} from '@sbb-esta/lyne-angular/tooltip';

@Component({
  selector: 'app-icon-sidebar',
  imports: [
    SbbIconSidebarContainer,
    SbbIconSidebar,
    SbbIconSidebarLink,
    SbbIconSidebarContent,
    SbbBlockLink,
    SbbSidebarContent,
    SbbLinkList,
    SbbSidebarCloseButton,
    SbbSidebarTitle,
    SbbSidebar,
    SbbSidebarContainer,
    SbbIconSidebarButton,
    SbbTooltipDirective,

  ],
  templateUrl: './icon-sidebar.html',
  styleUrl: './icon-sidebar.css',
})
export class IconSidebar {

}
