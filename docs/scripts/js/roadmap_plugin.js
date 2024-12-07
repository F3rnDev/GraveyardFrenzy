(function () {
    var roadmapPlugin = function (hook, vm) {
      hook.afterEach(function (html, next) {
        var roadmapSteps = [];

        // Regex para encontrar os itens do roadmap, padrão: [roadmap-items] ... [/roadmap-items]
        const regex = /\[roadmap-item\](.*?)\[roadmap-item\]/gs;
        
        let matches = html.match(regex);
        if (matches) {
          matches.forEach((match) => {
            const stepContent = match;

            const stepDetails = {};
            const attributes = [
              { key: 'title', regex: /\[title\](.*?)\[title\]/ },
              { key: 'date', regex: /\[date\](.*?)\[date\]/ },
              { key: 'description', regex: /\[description\](.*?)\[description\]/ },
              { key: 'progress', regex: /\[progress\](.*?)\[progress\]/ },
              { key: 'version', regex: /\[version\](.*?)\[version\]/ },
              { key: 'icon', regex: /\[icon\](.*?)\[icon\]/ },
            ];

            attributes.forEach(attr => {
                const attributeMatch = stepContent.match(attr.regex);
                if (attributeMatch) {
                    stepDetails[attr.key] = attributeMatch[1];
                }
            });

            stepDetails.current = stepContent.includes('[current]');
    
            if (stepDetails.title) {
                roadmapSteps.push(stepDetails);
            }
          });
        }
        
        html = html.replace(regex, '');

        var roadmapHTML = `
        <div class="roadmap">
          <div class="roadmap-line"></div>
          <div>
        `;
  
        roadmapSteps.forEach((step) => {

          const isCurrent = step.current ? '-progress' : '';

          var curIcon = `<i class="${step.icon || 'fa-solid fa-circle'}"></i>`;
          var displayStamp = '';

          //see it the icon is custom made
          if (step.icon && !step.icon.startsWith('fa-')) 
          {
            curIcon = `<img class="custom-icon" src="images/icons/${step.icon}.svg" data-no-zoom/>`;
          }
          else if (step.current)
          {
            curIcon = `<img class="custom-icon" src="images/icons/skeleton.svg" data-no-zoom style="width: 40px; height: 40px;"/>`;
            displayStamp = `<span class="displayStamp">HERE</span>`;
          }

          //check if the percentage is 100% or 0%
          var roadmapProgress = `<progress class="roadmap-ItemProgress roadmap-bar${isCurrent}" max='100' value='${step.progress}'></progress>`;
          if (step.progress == 100)
          {
            var roadmapProgress = `<span class="roadmap-ItemProgress">Done</span>`;
          }
          else if (step.progress == 0)
          {
            var roadmapProgress = `<span class="roadmap-ItemProgress">Not started</span>`;
          }

          roadmapHTML += `
          <div class="roadmap-content" id=${isCurrent}>
            <div class="roadmap-icon${isCurrent}">
              ${curIcon}
            </div>
            <div class="roadmap-item${isCurrent}" onclick="selectStep(this);">
              <div class="roadmap-header"> 
                <span class="roadmap-title">${step.title}</span>
                <span>${step.date}</span>
              </div>

              <div class="roadmap-description">
                <p>${step.description}</p>
              </div>

              <div class="roadmap-footer${isCurrent}">
                ${roadmapProgress}
                <span>${step.version}</span>
                ${displayStamp}
              </div>
              
            </div>
          </div>`;
       });
  
        roadmapHTML += `</div></div>`;

        html = html.replace('<div class="roadmap-container"></div>', roadmapHTML);
        next(html);

        var roadmapLine = document.querySelector('.roadmap-line');

        if(roadmapLine)
        {
          roadmapLine.style.height = document.querySelector('.roadmap').clientHeight + 'px';
        }
      });
    };
  
    // Adiciona o plugin ao Docsify
    $docsify = $docsify || {};
    $docsify.plugins = [].concat($docsify.plugins || [], roadmapPlugin);
})();