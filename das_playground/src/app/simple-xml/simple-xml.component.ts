import { AfterViewInit, Component, ElementRef, Input, Renderer2, inject } from '@angular/core';

@Component({
  selector: 'app-simple-xml',
  imports: [],
  templateUrl: './simple-xml.component.html',
  styleUrl: './simple-xml.component.scss'
})
export class SimpleXmlComponent implements AfterViewInit {
  private el = inject(ElementRef);
  private renderer = inject(Renderer2);

  @Input() xml: Document | undefined;
  @Input() xmlString: string | undefined;
  @Input() collapsedText: string = '...';
  @Input() collapsed: boolean = false;

  ngAfterViewInit() {
    if (this.xml === undefined && this.xmlString === undefined) {
      throw new Error("No XML to be displayed was supplied");
    }

    if (this.xml !== undefined && this.xmlString !== undefined) {
      throw new Error("Only one of xml and xmlString may be supplied");
    }

    let xml = this.xml;
    if (xml === undefined && this.xmlString) {
      const parser = new DOMParser();
      xml = parser.parseFromString(this.xmlString, 'text/xml');
    }

    const wrapperNode = this.renderer.createElement('span');
    this.renderer.addClass(wrapperNode, 'simpleXML');
    if (xml) {
      this.showNode(wrapperNode, xml, this.collapsed);
      this.renderer.appendChild(this.el.nativeElement, wrapperNode);

      const expanderHeaders = wrapperNode.querySelectorAll('.simpleXML-expanderHeader');
      expanderHeaders.forEach((header: HTMLElement) => {
        header.addEventListener('click', () => {
          const expanderHeader = header.closest('.simpleXML-expanderHeader') as HTMLElement;
          const expander = expanderHeader.querySelector('.simpleXML-expander') as HTMLElement;
          const content = expanderHeader.parentElement!.querySelector('.simpleXML-content') as HTMLElement;
          const collapsedText = expanderHeader.parentElement!.querySelector('.simpleXML-collapsedText') as HTMLElement;
          const closeExpander = expanderHeader.parentElement!.querySelector('.simpleXML-expanderClose') as HTMLElement;

          if (expander.classList.contains('simpleXML-expander-expanded')) {
            expander.classList.remove('simpleXML-expander-expanded');
            expander.classList.add('simpleXML-expander-collapsed');

            collapsedText.style.display = 'inline';
            content.style.display = 'none';
            closeExpander.style.display = 'none';
          } else {
            expander.classList.add('simpleXML-expander-expanded');
            expander.classList.remove('simpleXML-expander-collapsed');
            collapsedText.style.display = 'none';
            content.style.display = '';
            closeExpander.style.display = '';
          }
        });
      });
    }
  }

  private showNode(parent: HTMLElement, xml: Node, collapsed: boolean) {
    if (xml.nodeType == 9) {
      for (let i = 0; i < xml.childNodes.length; i++) {
        this.showNode(parent, xml.childNodes[i], collapsed);
      }
      return;
    }

    switch (xml.nodeType) {
      case Node.ELEMENT_NODE: {
        const hasChildNodes = xml.childNodes.length > 0;
        const expandingNode = hasChildNodes && (xml.childNodes.length > 1 || xml.childNodes[0].nodeType != 3);

        const expanderHeader = expandingNode ? this.makeSpan('', 'simpleXML-expanderHeader') : parent;

        const expanderSpan = this.makeSpan('', 'simpleXML-expander');
        if (expandingNode) {
          this.renderer.addClass(expanderSpan, 'simpleXML-expander-collapsed');
          this.renderer.addClass(expanderSpan, collapsed ? 'collapsed' : 'expanded');
        }
        this.renderer.appendChild(expanderHeader, expanderSpan);

        this.renderer.appendChild(expanderHeader, this.makeSpan('<', 'simpleXML-tagHeader'));
        this.renderer.appendChild(expanderHeader, this.makeSpan(xml.nodeName, 'simpleXML-tagValue'));

        if (expandingNode) {
          this.renderer.appendChild(parent, expanderHeader);
        }

        const attributes = (xml as Element).attributes;

        for (let attrIdx = 0; attrIdx < attributes.length; attrIdx++) {
          this.renderer.appendChild(expanderHeader, this.makeSpan(' '));
          this.renderer.appendChild(expanderHeader, this.makeSpan(attributes[attrIdx].name, 'simpleXML-attrName'));
          this.renderer.appendChild(expanderHeader, this.makeSpan('="'));
          this.renderer.appendChild(expanderHeader, this.makeSpan(attributes[attrIdx].value, 'simpleXML-attrValue'));
          this.renderer.appendChild(expanderHeader, this.makeSpan('"'));
        }

        if (hasChildNodes) {
          this.renderer.appendChild(parent, this.makeSpan('>', 'simpleXML-tagHeader'));

          if (expandingNode) {
            const ulElement = this.renderer.createElement('ul');
            for (let i = 0; i < xml.childNodes.length; i++) {
              const liElement = this.renderer.createElement('li');
              this.showNode(liElement, xml.childNodes[i], collapsed);
              this.renderer.appendChild(ulElement, liElement);
            }

            const collapsedTextStyle = collapsed ? 'inline' : 'none';
            const contentStyle = collapsed ? 'none' : '';
            const collapsedTextSpan = this.makeSpan(this.collapsedText, 'simpleXML-collapsedText');
            collapsedTextSpan.setAttribute('style', `display: ${collapsedTextStyle};`);
            ulElement.setAttribute('class', 'simpleXML-content');
            ulElement.setAttribute('style', `display: ${contentStyle};`);
            this.renderer.appendChild(parent, collapsedTextSpan);
            this.renderer.appendChild(parent, ulElement);

            this.renderer.appendChild(parent, this.makeSpan('', 'simpleXML-expanderClose'));
          } else {
            this.renderer.appendChild(parent, this.makeSpan(xml.childNodes[0].nodeValue!));
          }

          this.renderer.appendChild(parent, this.makeSpan('</', 'simpleXML-tagHeader'));
          this.renderer.appendChild(parent, this.makeSpan(xml.nodeName, 'simpleXML-tagValue'));
          this.renderer.appendChild(parent, this.makeSpan('>', 'simpleXML-tagHeader'));
        } else {
          const closingSpan = this.renderer.createElement('span');
          closingSpan.innerText = '/>';
          this.renderer.appendChild(parent, closingSpan);
        }
      }
        break;

      case 3: {
        if (xml.nodeValue && xml.nodeValue.trim() !== '') {
          this.renderer.appendChild(parent, this.makeSpan('', 'simpleXML-expander'));
          this.renderer.appendChild(parent, this.makeSpan(xml.nodeValue));
        }
      }
        break;

      case 4: {
        this.renderer.appendChild(parent, this.makeSpan('', 'simpleXML-expander'));
        this.renderer.appendChild(parent, this.makeSpan('<![CDATA[', 'simpleXML-tagHeader'));
        this.renderer.appendChild(parent, this.makeSpan(xml.nodeValue!, 'simpleXML-cdata'));
        this.renderer.appendChild(parent, this.makeSpan(']]>', 'simpleXML-tagHeader'));
      }
        break;

      case 8: {
        this.renderer.appendChild(parent, this.makeSpan('', 'simpleXML-expander'));
        this.renderer.appendChild(parent, this.makeSpan(`<!--${xml.nodeValue}-->`, 'simpleXML-comment'));
      }
        break;

      default: {
        const item = this.renderer.createElement('span');
        item.innerText = `${xml.nodeType} - ${xml.nodeName}`;
        this.renderer.appendChild(parent, item);
      }
        break;
    }
  }

  private makeSpan(innerText: string, classes?: string): HTMLElement {
    const span = this.renderer.createElement('span');
    span.innerText = innerText;

    if (classes !== undefined) {
      this.renderer.addClass(span, classes);
    }

    return span;
  }
}
