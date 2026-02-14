const pptxgen = require('pptxgenjs');
const html2pptx = require('/home/talal/.claude/plugins/cache/anthropic-agent-skills/document-skills/69c0b1a06741/skills/pptx/scripts/html2pptx.js');
const path = require('path');

async function createPresentation() {
    const pptx = new pptxgen();
    pptx.layout = 'LAYOUT_16x9';
    pptx.author = 'Talal Ahmed';
    pptx.title = 'Design Buildings Using Natural Language - Revit MCP';
    pptx.subject = 'Connecting Claude Code AI to Autodesk Revit 2026 via MCP';

    const slidesDir = __dirname + '/slides';

    // 15 slides - complete presentation flow
    const slides = [
        'slide01-title.html',          // 1. Title
        'slide02-revit.html',           // 2. What is Revit? (NEW)
        'slide03-bim-vs-cad.html',      // 3. BIM vs CAD (NEW)
        'slide04-bim.html',             // 4. What is BIM? (Model/Modelling/Management)
        'slide05-parametric.html',      // 5. Parametric Modeling
        'slide02-problem.html',         // 6. The Problem
        'slide03-solution.html',        // 7. The Solution
        'slide07-mcp.html',             // 8. What is MCP?
        'slide06-architecture.html',    // 9. System Architecture
        'slide08-commands.html',        // 10. Available Tools (19 commands)
        'slide11-examples.html',        // 11. Natural Language in Action (NEW)
        'slide09-demo.html',            // 12. Live Demo Results
        'slide13-digital-twins.html',   // 13. Digital Twins + IoT (NEW)
        'slide14-setup.html',           // 14. Setup Guide (improved)
        'slide15-thanks.html',          // 15. Thank You
    ];

    for (let i = 0; i < slides.length; i++) {
        console.log(`Converting slide ${i + 1}/${slides.length}: ${slides[i]}...`);
        await html2pptx(path.join(slidesDir, slides[i]), pptx);
    }

    const outputPath = path.join(__dirname, 'Revit-MCP-Presentation.pptx');
    await pptx.writeFile({ fileName: outputPath });
    console.log(`\nPresentation created successfully: ${outputPath}`);
    console.log(`Total slides: ${slides.length}`);
}

createPresentation().catch(err => {
    console.error('Error:', err.message || err);
    process.exit(1);
});
